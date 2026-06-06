import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';
import '../repositories/sales_repository.dart';
import '../models/sale_model.dart';

/// ─────────────────────────────────────────────────────────────
///  TRANSACTIONS SCREEN  –  lib/screens/transactions_screen.dart
///  Items count fixed via FutureBuilder
/// ─────────────────────────────────────────────────────────────
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _repo = SalesRepository();

  List<SaleModel> _allSales = [];
  List<SaleModel> _filtered = [];
  bool            _loading  = true;

  String _search = '';
  String _period = 'Today';
  String _method = 'All Payment Methods';
  int    _page   = 1;
  static const _perPage = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    List<SaleModel> sales;
    switch (_period) {
      case 'Today':
        sales = await _repo.getTodaySales();
        break;
      case 'Yesterday':
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final start = DateTime(yesterday.year, yesterday.month, yesterday.day);
        final end   = start.add(const Duration(days: 1));
        sales = await _repo.getByDateRange(start, end);
        break;
      case 'Last 7 Days':
        sales = await _repo.getByDateRange(
            DateTime.now().subtract(const Duration(days: 7)), DateTime.now());
        break;
      case 'Last 30 Days':
        sales = await _repo.getByDateRange(
            DateTime.now().subtract(const Duration(days: 30)), DateTime.now());
        break;
      default:
        sales = await _repo.getAllSales(limit: 200);
    }
    setState(() {
      _allSales = sales;
      _applyFilters();
      _loading  = false;
    });
  }

  void _applyFilters() {
    _filtered = _allSales.where((t) {
      final q           = _search.toLowerCase();
      final matchSearch = _search.isEmpty ||
          t.invoiceId.toLowerCase().contains(q) ||
          t.customer.toLowerCase().contains(q);
      final matchMethod = _method == 'All Payment Methods' ||
          (_method == 'Cash' && t.paymentMethod == PaymentMethod.cash) ||
          (_method == 'UPI'  && t.paymentMethod == PaymentMethod.upi)  ||
          (_method == 'Card' && t.paymentMethod == PaymentMethod.card);
      return matchSearch && matchMethod;
    }).toList();
  }

  List<SaleModel> get _paged {
    final start = (_page - 1) * _perPage;
    final end   = (start + _perPage).clamp(0, _filtered.length);
    return start >= _filtered.length ? [] : _filtered.sublist(start, end);
  }

  int get _totalPages =>
      (_filtered.length / _perPage).ceil().clamp(1, 9999);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(c),
        _buildFiltersRow(c),
        _buildTableHeader(c),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
            ? Center(child: Text('No transactions found.',
            style: TextStyle(color: c.textMuted, fontSize: 14)))
            : ListView.separated(
          itemCount: _paged.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: c.borderLight),
          itemBuilder: (ctx, i) {
            final tx = _paged[i];
            // FutureBuilder to get real item count from DB
            return FutureBuilder(
              future: tx.id != null
                  ? _repo.getSaleItems(tx.id!)
                  : Future.value([]),
              builder: (ctx, snap) => _TransactionRow(
                tx:        tx,
                itemCount: snap.data?.length ?? 0,
                onRefund:  () => _onRefund(tx),
              ),
            );
          },
        )),
        _buildFooter(c),
      ]),
    );
  }

  Widget _buildHeader(AdaptiveColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.borderLight))),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: AppColors.teal50,
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.receipt_long_outlined,
              color: AppColors.teal600, size: 20),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Transaction History', style: AppTextStyles.h2),
          const SizedBox(height: 2),
          Text('View and manage past bills and refunds',
              style: AppTextStyles.caption),
        ]),
        const Spacer(),
        // Refresh
        IconButton(
          onPressed: _loadData,
          icon: Icon(Icons.refresh, color: c.textSub),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_outlined, size: 16),
          label: const Text('Export CSV'),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.textSecond,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            side: BorderSide(color: c.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }

  Widget _buildFiltersRow(AdaptiveColors c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.borderLight))),
      child: Row(children: [
        SizedBox(
          width: 300, height: 38,
          child: TextField(
            onChanged: (v) =>
                setState(() { _search = v; _page = 1; _applyFilters(); }),
            decoration: InputDecoration(
              hintText: 'Search by Invoice or Customer…',
              prefixIcon: Icon(Icons.search, size: 16, color: c.textMuted),
              filled: true, fillColor: c.inputFill,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: c.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: c.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppColors.teal600, width: 1.5)),
              hintStyle: TextStyle(fontSize: 13, color: c.textMuted),
            ),
            style: TextStyle(fontSize: 13, color: c.textPrimary),
          ),
        ),
        const SizedBox(width: 10),
        _DDFilter(
          value: _period,
          items: const [
            'Today', 'Yesterday', 'Last 7 Days', 'Last 30 Days', 'All Time'
          ],
          onChanged: (v) {
            setState(() { _period = v ?? _period; _page = 1; });
            _loadData();
          },
          c: c,
        ),
        const SizedBox(width: 10),
        _DDFilter(
          value: _method,
          items: const [
            'All Payment Methods', 'Cash', 'UPI', 'Card'
          ],
          onChanged: (v) => setState(() {
            _method = v ?? _method;
            _page   = 1;
            _applyFilters();
          }),
          c: c,
          width: 190,
        ),
      ]),
    );
  }

  Widget _buildTableHeader(AdaptiveColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: c.tableHeader,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(children: [
        _TH('DATE & TIME',   3, c),
        _TH('INVOICE ID',    3, c),
        _TH('CUSTOMER',      4, c),
        _TH('ITEMS',         2, c, center: true),
        _TH('METHOD',        3, c, center: true),
        _TH('AMOUNT',        3, c, right: true),
        _TH('STATUS',        2, c, center: true),
        _TH('ACTIONS',       2, c, center: true),
      ]),
    );
  }

  Widget _buildFooter(AdaptiveColors c) {
    final total = _filtered.length;
    final start = (_page - 1) * _perPage + 1;
    final end   = (start + _perPage - 1).clamp(1, total.clamp(1, 9999));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.border))),
      child: Row(children: [
        Text(
          total == 0
              ? 'No transactions'
              : 'Showing $start–$end of $total transactions',
          style: AppTextStyles.caption,
        ),
        const Spacer(),
        _PaginationBar(
          current:   _page,
          total:     _totalPages,
          onChanged: (p) => setState(() => _page = p),
        ),
      ]),
    );
  }

  Future<void> _onRefund(SaleModel sale) async {
    if (sale.id == null) return;
    final c       = context.colors;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.cardBg,
        title: Text('Confirm Refund',
            style: TextStyle(color: c.textPrimary)),
        content: Text(
            'Mark invoice ${sale.invoiceId} as refunded?',
            style: TextStyle(color: c.textSecond)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Refund',
                style: TextStyle(color: AppColors.red500)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _repo.refundSale(sale.id!);
      _loadData();
    }
  }
}

// ── Transaction row ───────────────────────────────────────────
class _TransactionRow extends StatefulWidget {
  final SaleModel  tx;
  final int        itemCount;
  final VoidCallback onRefund;
  const _TransactionRow(
      {required this.tx,
        required this.itemCount,
        required this.onRefund});
  @override
  State<_TransactionRow> createState() => _TransactionRowState();
}

class _TransactionRowState extends State<_TransactionRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final c  = context.colors;
    final dt = widget.tx.createdAt;
    final dateStr =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final h     = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm  = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr =
        '$h:${dt.minute.toString().padLeft(2, '0')} $amPm';

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hov ? c.rowHover : c.cardBg,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(children: [
          // Date & Time
          Expanded(flex: 3,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr, style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w600, color: c.textPrimary)),
                    Text(timeStr, style: TextStyle(
                        fontSize: 12, color: c.textMuted)),
                  ])),
          // Invoice ID
          Expanded(flex: 3,
              child: Text(widget.tx.invoiceId,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.teal600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.teal600))),
          // Customer
          Expanded(flex: 4,
              child: Text(widget.tx.customer,
                  style: TextStyle(fontSize: 14, color: c.textSecond))),
          // Items count — real from DB via FutureBuilder
          Expanded(flex: 2,
              child: Center(child: Text(
                '${widget.itemCount}',
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600, color: c.textPrimary),
              ))),
          // Payment chip
          Expanded(flex: 3,
              child: Center(child: _PayChip(widget.tx.paymentMethod))),
          // Amount
          Expanded(flex: 3,
              child: Text('₹${widget.tx.total.toStringAsFixed(2)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w700, color: c.textPrimary))),
          // Status
          Expanded(flex: 2,
              child: Center(child: _StatusBadge(widget.tx.status))),
          // Actions
          Expanded(flex: 2,
              child: AnimatedOpacity(
                opacity: _hov ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _IBtn(Icons.visibility_outlined, 'View',
                          context.colors.textSub, () {}),
                      const SizedBox(width: 4),
                      _IBtn(Icons.print_outlined, 'Print',
                          context.colors.textSub, () {}),
                      if (widget.tx.status != SaleStatus.refunded) ...[
                        const SizedBox(width: 4),
                        _IBtn(Icons.undo_outlined, 'Refund',
                            AppColors.red500, widget.onRefund),
                      ],
                    ]),
              )),
        ]),
      ),
    );
  }
}

// ── Payment chip ──────────────────────────────────────────────
class _PayChip extends StatelessWidget {
  final PaymentMethod m;
  const _PayChip(this.m);
  @override
  Widget build(BuildContext context) {
    final cfgs = {
      PaymentMethod.upi:  (l: 'UPI',  bg: const Color(0xFFEDE9FE),
      fg: const Color(0xFF6D28D9)),
      PaymentMethod.card: (l: 'Card', bg: const Color(0xFFE0F2FE),
      fg: const Color(0xFF0369A1)),
      PaymentMethod.cash: (l: 'Cash', bg: const Color(0xFFFEF9C3),
      fg: const Color(0xFF92400E)),
    };
    final cfg = cfgs[m]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: cfg.bg, borderRadius: BorderRadius.circular(20)),
      child: Text(cfg.l,
          style: TextStyle(fontSize: 12,
              fontWeight: FontWeight.w700, color: cfg.fg)),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final SaleStatus s;
  const _StatusBadge(this.s);
  @override
  Widget build(BuildContext context) {
    final cfgs = {
      SaleStatus.completed: (l: 'Completed',
      bg: AppColors.green100, fg: AppColors.green700),
      SaleStatus.refunded:  (l: 'Refunded',
      bg: AppColors.red100, fg: AppColors.red700),
      SaleStatus.pending:   (l: 'Pending',
      bg: const Color(0xFFFEF9C3), fg: const Color(0xFF92400E)),
    };
    final cfg = cfgs[s]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: cfg.bg, borderRadius: BorderRadius.circular(20)),
      child: Text(cfg.l,
          style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: cfg.fg)),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────
Widget _TH(String text, int flex, AdaptiveColors c,
    {bool center = false, bool right = false}) =>
    Expanded(
      flex: flex,
      child: Text(text,
          textAlign: right
              ? TextAlign.right
              : center
              ? TextAlign.center
              : TextAlign.left,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.textSub,
              letterSpacing: 0.5)),
    );

class _DDFilter extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final AdaptiveColors c;
  final double width;
  const _DDFilter(
      {required this.value,
        required this.items,
        required this.onChanged,
        required this.c,
        this.width = 150});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: c.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          dropdownColor: c.cardBg,
          items: items
              .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e,
                  style: TextStyle(
                      fontSize: 13, color: c.textSecond),
                  overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 16, color: c.textSub),
        ),
      ),
    );
  }
}

class _IBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _IBtn(this.icon, this.tooltip, this.color, this.onTap);
  @override
  State<_IBtn> createState() => _IBtnState();
}

class _IBtnState extends State<_IBtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit:  (_) => setState(() => _hov = false),
    cursor: SystemMouseCursors.click,
    child: Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hov
                ? widget.color.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon, size: 16,
              color: _hov ? widget.color : context.colors.textMuted),
        ),
      ),
    ),
  );
}

class _PaginationBar extends StatelessWidget {
  final int current, total;
  final ValueChanged<int> onChanged;
  const _PaginationBar(
      {required this.current,
        required this.total,
        required this.onChanged});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(children: [
      _PgBtn(Icons.chevron_left,
          current > 1 ? () => onChanged(current - 1) : null, c),
      ...List.generate(
        total.clamp(1, 5),
            (i) => _PgNum(i + 1, current == i + 1, () => onChanged(i + 1), c),
      ),
      _PgBtn(Icons.chevron_right,
          current < total ? () => onChanged(current + 1) : null, c),
    ]);
  }
}

Widget _PgBtn(IconData icon, VoidCallback? onTap, AdaptiveColors c) =>
    Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
                border: Border.all(color: c.border),
                borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, size: 18,
                color: onTap == null ? c.textMuted : c.textSecond)),
      ),
    );

Widget _PgNum(int n, bool active, VoidCallback onTap, AdaptiveColors c) =>
    Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
              color: active ? AppColors.teal600 : c.cardBg,
              border: Border.all(
                  color: active ? AppColors.teal600 : c.border),
              borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: Text('$n',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.white : c.textSecond)),
          ),
        ),
      ),
    );