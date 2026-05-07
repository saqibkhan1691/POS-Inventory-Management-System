import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/product_tile.dart';

/// ─────────────────────────────────────────────────────────────
///  INVENTORY SCREEN  –  Product list with search & filters
///  File: lib/screens/inventory_screen.dart
/// ─────────────────────────────────────────────────────────────

const _dummyProducts = [
  ProductTileData(id:'1', name:'Banarasi Silk Saree - Red',   barcode:'890123', category:'Silk Sarees',    price:4500, stock:12),
  ProductTileData(id:'2', name:'Kanjeevaram Silk - Blue',      barcode:'890124', category:'Silk Sarees',    price:6200, stock:5 ),
  ProductTileData(id:'3', name:'Cotton Printed Saree',         barcode:'890125', category:'Cotton Sarees',  price:850,  stock:40),
  ProductTileData(id:'4', name:'Georgette Designer Saree',     barcode:'890126', category:'Designer Wear',  price:2100, stock:0 ),
  ProductTileData(id:'5', name:'Mysore Silk Saree',            barcode:'890127', category:'Silk Sarees',    price:3200, stock:18),
  ProductTileData(id:'6', name:'Linen Blend Daily Wear',       barcode:'890128', category:'Cotton Sarees',  price:1200, stock:25),
  ProductTileData(id:'7', name:'Pure Chanderi Silk',           barcode:'890129', category:'Silk Sarees',    price:5100, stock:3 ),
  ProductTileData(id:'8', name:'Embroidered Georgette',        barcode:'890130', category:'Designer Wear',  price:3800, stock:7 ),
];

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _search   = '';
  String _category = 'All Categories';
  String _status   = 'All Status';
  int    _page     = 1;

  List<ProductTileData> get _filtered {
    return _dummyProducts.where((p) {
      final matchSearch =
          _search.isEmpty ||
              p.name.toLowerCase().contains(_search.toLowerCase()) ||
              p.barcode.contains(_search);
      final matchCat =
          _category == 'All Categories' || p.category == _category;
      final matchStatus = _status == 'All Status' ||
          (_status == 'In Stock'    && p.status == StockStatus.inStock) ||
          (_status == 'Low Stock'   && p.status == StockStatus.lowStock) ||
          (_status == 'Out of Stock'&& p.status == StockStatus.outOfStock);
      return matchSearch && matchCat && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────
          _Header(
            onSearchChanged: (v) => setState(() => _search = v),
            onCategoryChanged: (v) => setState(() => _category = v ?? 'All Categories'),
            onStatusChanged: (v) => setState(() => _status = v ?? 'All Status'),
          ),

          // ── Table header ─────────────────────────────────
          Container(
            // color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 4, child: _TH('Product Info')),
                Expanded(flex: 2, child: _TH('Barcode / SKU')),
                SizedBox(width: 110, child: _TH('Price',   align: TextAlign.right)),
                SizedBox(width: 80,  child: _TH('Stock',   align: TextAlign.right)),
                SizedBox(width: 120, child: _TH('Status',  align: TextAlign.center)),
                SizedBox(width: 80,  child: _TH('Actions', align: TextAlign.center)),
              ],
            ),
          ),

          // ── Rows ─────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? const Center(
                child: Text('No products found.',
                    style: AppTextStyles.body))
                : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppColors.gray100),
              itemBuilder: (ctx, i) => ProductTile(
                product: items[i],
                index: i + 1,
              ),
            ),
          ),

          // ── Pagination ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.gray200)),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Text(
                  'Showing ${items.length} of ${_dummyProducts.length} results',
                  style: AppTextStyles.caption,
                ),
                const Spacer(),
                _Pagination(
                  currentPage: _page,
                  totalPages: 3,
                  onPageChanged: (p) => setState(() => _page = p),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _TH extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _TH(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: align,
        style: AppTextStyles.captionBold);
  }
}

class _Header extends StatelessWidget {
  final ValueChanged<String>  onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;

  const _Header({
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: AppColors.teal600, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inventory Management', style: AppTextStyles.h2),
                  const SizedBox(height: 1),
                  Text('View and manage your product stock',
                      style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Search
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by product name, barcode…',
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: AppColors.gray400),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: const BorderSide(color: AppColors.gray300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: const BorderSide(color: AppColors.gray300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide:
                        const BorderSide(color: AppColors.teal600, width: 1.5),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Category dropdown
              _DropdownFilter(
                value: 'All Categories',
                items: const [
                  'All Categories', 'Silk Sarees', 'Cotton Sarees', 'Designer Wear'
                ],
                onChanged: onCategoryChanged,
              ),
              const SizedBox(width: 8),

              // Status dropdown
              _DropdownFilter(
                value: 'All Status',
                items: const [
                  'All Status', 'In Stock', 'Low Stock', 'Out of Stock'
                ],
                onChanged: onStatusChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.gray300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: onChanged,
          style: AppTextStyles.body,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: AppColors.gray500),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const _Pagination(
      {required this.currentPage,
        required this.totalPages,
        required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PageBtn(
          icon: Icons.chevron_left,
          onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        ...List.generate(
          totalPages,
              (i) => _PageNumBtn(
            number: i + 1,
            isActive: currentPage == i + 1,
            onTap: () => onPageChanged(i + 1),
          ),
        ),
        _PageBtn(
          icon: Icons.chevron_right,
          onTap:
          currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PageBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon,
              size: 18,
              color: onTap == null ? AppColors.gray300 : AppColors.gray600),
        ),
      ),
    );
  }
}

class _PageNumBtn extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback onTap;
  const _PageNumBtn(
      {required this.number, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.teal600 : AppColors.white,
            border: Border.all(
                color: isActive ? AppColors.teal600 : AppColors.gray300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.white : AppColors.gray700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
