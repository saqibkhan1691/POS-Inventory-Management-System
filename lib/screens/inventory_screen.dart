import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/product_tile.dart';
import '../core/app_colors_ext.dart';
import '../repositories/product_repository.dart';
import '../models/product_model.dart';

/// ─────────────────────────────────────────────────────────────
///  INVENTORY SCREEN  –  lib/screens/inventory_screen.dart
///  Now reads from SQLite via ProductRepository
/// ─────────────────────────────────────────────────────────────
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _repo = ProductRepository();

  List<ProductModel> _allProducts  = [];
  List<ProductModel> _filtered     = [];
  List<String>       _categories   = ['All Categories'];
  bool               _loading      = true;

  String _search   = '';
  String _category = 'All Categories';
  String _status   = 'All Status';
  int    _page     = 1;
  static const _perPage = 8;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final products   = await _repo.getAllProducts();
    final categories = await _repo.getCategories();
    setState(() {
      _allProducts = products;
      _categories  = ['All Categories', ...categories];
      _applyFilters();
      _loading     = false;
    });
  }

  void _applyFilters() {
    _filtered = _allProducts.where((p) {
      final q           = _search.toLowerCase();
      final matchSearch = _search.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.barcode.contains(q);
      final matchCat    = _category == 'All Categories' || p.category == _category;
      final matchStatus = _status == 'All Status' ||
          (_status == 'In Stock'     && p.stock > p.alertQty) ||
          (_status == 'Low Stock'    && p.stock > 0 && p.stock <= p.alertQty) ||
          (_status == 'Out of Stock' && p.stock == 0);
      return matchSearch && matchCat && matchStatus;
    }).toList();
  }

  // Convert ProductModel → ProductTileData for the widget
  ProductTileData _toTileData(ProductModel p) => ProductTileData(
    id:       p.id.toString(),
    name:     p.name,
    barcode:  p.barcode,
    category: p.category,
    price:    p.sellingPrice,
    stock:    p.stock,
  );

  List<ProductModel> get _paged {
    final start = (_page - 1) * _perPage;
    final end   = (start + _perPage).clamp(0, _filtered.length);
    return start >= _filtered.length ? [] : _filtered.sublist(start, end);
  }

  int get _totalPages => (_filtered.length / _perPage).ceil().clamp(1, 9999);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(children: [
        _buildHeader(c),
        _buildTableHeader(c),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
            ? Center(child: Text('No products found.',
            style: TextStyle(color: c.textMuted, fontSize: 14)))
            : ListView.separated(
          itemCount: _paged.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: c.borderLight),
          itemBuilder: (ctx, i) => ProductTile(
            product:  _toTileData(_paged[i]),
            index:    (_page - 1) * _perPage + i + 1,
            onEdit:   () => _onEdit(_paged[i]),
            onDelete: () => _onDelete(_paged[i]),
          ),
        )),
        _buildFooter(c),
      ]),
    );
  }

  Widget _buildHeader(AdaptiveColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        color: c.tableHeader,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.inventory_2_outlined, color: AppColors.teal600, size: 22),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Inventory Management', style: AppTextStyles.h2),
            const SizedBox(height: 1),
            Text('View and manage your product stock', style: AppTextStyles.caption),
          ]),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal600,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: SizedBox(
            height: 38,
            child: TextField(
              onChanged: (v) => setState(() { _search = v; _page = 1; _applyFilters(); }),
              decoration: InputDecoration(
                hintText: 'Search by product name, barcode…',
                prefixIcon: Icon(Icons.search, size: 18, color: c.textMuted),
                filled: true, fillColor: c.inputFill,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(color: c.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(color: c.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(color: AppColors.teal600, width: 1.5)),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          )),
          const SizedBox(width: 10),
          _DropdownFilter(
            value: _category,
            items: _categories,
            onChanged: (v) => setState(() { _category = v ?? 'All Categories'; _page = 1; _applyFilters(); }),
          ),
          const SizedBox(width: 8),
          _DropdownFilter(
            value: _status,
            items: const ['All Status','In Stock','Low Stock','Out of Stock'],
            onChanged: (v) => setState(() { _status = v ?? 'All Status'; _page = 1; _applyFilters(); }),
          ),
        ]),
      ]),
    );
  }

  Widget _buildTableHeader(AdaptiveColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: c.tableHeader,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(children: [
        Expanded(flex: 4, child: _TH('Product Info',    c)),
        Expanded(flex: 2, child: _TH('Barcode / SKU',  c)),
        SizedBox(width: 110, child: _TH('Price',   c, right: true)),
        SizedBox(width: 80,  child: _TH('Stock',   c, right: true)),
        SizedBox(width: 120, child: _TH('Status',  c, center: true)),
        SizedBox(width: 80,  child: _TH('Actions', c, center: true)),
      ]),
    );
  }

  Widget _buildFooter(AdaptiveColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: c.cardBg,
        border: Border(top: BorderSide(color: c.border)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      child: Row(children: [
        Text('Showing ${_paged.length} of ${_filtered.length} results',
            style: AppTextStyles.caption),
        const Spacer(),
        _Pagination(currentPage: _page, totalPages: _totalPages,
            onPageChanged: (p) => setState(() => _page = p)),
      ]),
    );
  }

  Future<void> _onEdit(ProductModel p) async {
    // Navigate to Add/Edit product screen with existing data
    // TODO: pass p to AddProductScreen for editing
  }

  Future<void> _onDelete(ProductModel p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${p.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
    if (confirm == true && p.id != null) {
      await _repo.deleteProduct(p.id!);
      _loadData();
    }
  }
}

// ── Shared small widgets ──────────────────────────────────────
Widget _TH(String text, AdaptiveColors c,
    {bool center = false, bool right = false}) =>
    Text(text,
        textAlign: right ? TextAlign.right : center ? TextAlign.center : TextAlign.left,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: c.textSub, letterSpacing: 0.5));

class _DropdownFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownFilter({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: c.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          dropdownColor: c.cardBg,
          items: items.map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: TextStyle(fontSize: 13, color: c.textSecond)))).toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: c.textMuted),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int currentPage, totalPages;
  final ValueChanged<int> onPageChanged;
  const _Pagination({required this.currentPage, required this.totalPages, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(children: [
      _PBtn(Icons.chevron_left, currentPage > 1 ? () => onPageChanged(currentPage - 1) : null, c),
      ...List.generate(totalPages.clamp(1, 5), (i) => _PNum(i + 1, currentPage == i + 1, () => onPageChanged(i + 1), c)),
      _PBtn(Icons.chevron_right, currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null, c),
    ]);
  }
}

Widget _PBtn(IconData icon, VoidCallback? onTap, AdaptiveColors c) =>
    Padding(padding: const EdgeInsets.only(right: 4),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6),
            child: Container(width: 32, height: 32,
                decoration: BoxDecoration(border: Border.all(color: c.border), borderRadius: BorderRadius.circular(6)),
                child: Icon(icon, size: 18, color: onTap == null ? c.textMuted : c.textSecond))));

Widget _PNum(int n, bool active, VoidCallback onTap, AdaptiveColors c) =>
    Padding(padding: const EdgeInsets.only(right: 4),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(6),
            child: Container(width: 32, height: 32,
                decoration: BoxDecoration(
                    color: active ? AppColors.teal600 : c.cardBg,
                    border: Border.all(color: active ? AppColors.teal600 : c.border),
                    borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('$n', style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.white : c.textSecond))))));