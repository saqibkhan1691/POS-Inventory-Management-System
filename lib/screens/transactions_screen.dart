import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  TRANSACTIONS SCREEN  –  lib/screens/billing_screen.dart
///  Transaction History table with filters, status badges,
///  payment method chips, Export CSV button, pagination
/// ─────────────────────────────────────────────────────────────

// ── Data model (UI-only, no DB yet) ──────────────────────────
enum TxStatus { completed, refunded, pending }
enum TxPayment { cash, upi, card }

class TransactionItem {
  final String invoiceId;
  final String dateTime;
  final String customer;
  final int items;
  final TxPayment payment;
  final double amount;
  final TxStatus status;

  const TransactionItem({
    required this.invoiceId,
    required this.dateTime,
    required this.customer,
    required this.items,
    required this.payment,
    required this.amount,
    required this.status,
  });
}

const _dummyTransactions = [
  TransactionItem(invoiceId: 'INV-2026-001', dateTime: '2026-05-04\n10:15 AM', customer: 'Walk-in Customer', items: 3,  payment: TxPayment.upi,  amount: 12500, status: TxStatus.completed),
  TransactionItem(invoiceId: 'INV-2026-002', dateTime: '2026-05-04\n11:30 AM', customer: 'Anjali S.',         items: 1,  payment: TxPayment.card, amount: 4500,  status: TxStatus.completed),
  TransactionItem(invoiceId: 'INV-2026-003', dateTime: '2026-05-04\n01:45 PM', customer: 'Walk-in Customer', items: 5,  payment: TxPayment.cash, amount: 2400,  status: TxStatus.completed),
  TransactionItem(invoiceId: 'INV-2026-004', dateTime: '2026-05-04\n02:20 PM', customer: 'Meera K.',          items: 2,  payment: TxPayment.card, amount: 6800,  status: TxStatus.refunded),
  TransactionItem(invoiceId: 'INV-2026-005', dateTime: '2026-05-03\n09:10 AM', customer: 'Neha R.',           items: 4,  payment: TxPayment.upi,  amount: 18500, status: TxStatus.completed),
  TransactionItem(invoiceId: 'INV-2026-006', dateTime: '2026-05-03\n04:55 PM', customer: 'Walk-in Customer', items: 1,  payment: TxPayment.cash, amount: 850,   status: TxStatus.completed),
];

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _search  = '';
  String _period  = 'Today';
  String _method  = 'All Payment Methods';
  int    _page    = 1;
  static const _perPage = 6;

  List<TransactionItem> get _filtered {
    return _dummyTransactions.where((t) {
      final q = _search.toLowerCase();
      final matchSearch = _search.isEmpty ||
          t.invoiceId.toLowerCase().contains(q) ||
          t.customer.toLowerCase().contains(q);
      final matchMethod = _method == 'All Payment Methods' ||
          (_method == 'Cash' && t.payment == TxPayment.cash) ||
          (_method == 'UPI'  && t.payment == TxPayment.upi)  ||
          (_method == 'Card' && t.payment == TxPayment.card);
      return matchSearch && matchMethod;
    }).toList();
  }

  List<TransactionItem> get _paged {
    final all  = _filtered;
    final start = (_page - 1) * _perPage;
    final end   = (start + _perPage).clamp(0, all.length);
    return start >= all.length ? [] : all.sublist(start, end);
  }

  int get _totalPages => ((_filtered.length) / _perPage).ceil().clamp(1, 9999);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildFiltersRow(),
          _buildTableHeader(),
          Expanded(child: _buildRows()),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: AppColors.teal600, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transaction History', style: AppTextStyles.h2),
              const SizedBox(height: 2),
              Text('View and manage past bills and refunds',
                  style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          // Export CSV button
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, size: 16),
            label: const Text('Export CSV'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gray700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: const BorderSide(color: AppColors.gray300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filters row ──────────────────────────────────────────
  Widget _buildFiltersRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 320,
            height: 38,
            child: TextField(
              onChanged: (v) => setState(() { _search = v; _page = 1; }),
              decoration: InputDecoration(
                hintText: 'Search by Invoice ID or Customer Name…',
                prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.gray400),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.gray300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.teal600, width: 1.5),
                ),
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),

          // Period dropdown
          _FilterDropdown(
            value: _period,
            items: const ['Today', 'Yesterday', 'Last 7 Days', 'Last 30 Days', 'Custom'],
            onChanged: (v) => setState(() => _period = v ?? _period),
          ),
          const SizedBox(width: 10),

          // Payment method dropdown
          _FilterDropdown(
            value: _method,
            items: const ['All Payment Methods', 'Cash', 'UPI', 'Card'],
            onChanged: (v) => setState(() => _method = v ?? _method),
            width: 190,
          ),
          const SizedBox(width: 10),

          // More Filters button
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 16),
            label: const Text('More Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gray600,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              side: const BorderSide(color: AppColors.gray300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Table header ─────────────────────────────────────────
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.gray50,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: const Row(
        children: [
          _TH('DATE & TIME',      flex: 3),
          _TH('INVOICE ID',       flex: 3),
          _TH('CUSTOMER',         flex: 4),
          _TH('ITEMS',            flex: 2, align: TextAlign.center),
          _TH('PAYMENT METHOD',   flex: 3, align: TextAlign.center),
          _TH('AMOUNT',           flex: 3, align: TextAlign.right),
          _TH('STATUS',           flex: 2, align: TextAlign.center),
          _TH('ACTIONS',          flex: 2, align: TextAlign.center),
        ],
      ),
    );
  }

  // ── Table rows ───────────────────────────────────────────
  Widget _buildRows() {
    final rows = _paged;
    if (rows.isEmpty) {
      return const Center(
        child: Text('No transactions found.',
            style: TextStyle(color: AppColors.gray400, fontSize: 14)),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: AppColors.gray100),
      itemBuilder: (ctx, i) => _TransactionRow(tx: rows[i]),
    );
  }

  // ── Footer / pagination ──────────────────────────────────
  Widget _buildFooter() {
    final total = _filtered.length;
    final start = (_page - 1) * _perPage + 1;
    final end   = (start + _perPage - 1).clamp(1, total);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $start to $end of $total transactions today',
            style: AppTextStyles.caption,
          ),
          const Spacer(),
          _PaginationBar(
            current: _page,
            total: _totalPages,
            onChanged: (p) => setState(() => _page = p),
          ),
        ],
      ),
    );
  }
}

// ── Transaction row ───────────────────────────────────────────────────────────
class _TransactionRow extends StatefulWidget {
  final TransactionItem tx;
  const _TransactionRow({required this.tx});

  @override
  State<_TransactionRow> createState() => _TransactionRowState();
}

class _TransactionRowState extends State<_TransactionRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hov ? AppColors.slate50 : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // Date & Time
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tx.dateTime.split('\n').map((l) {
                  final isTime = l.contains('AM') || l.contains('PM');
                  return Text(l,
                      style: isTime
                          ? AppTextStyles.caption
                          : AppTextStyles.bodyBold.copyWith(fontSize: 13));
                }).toList(),
              ),
            ),

            // Invoice ID — teal link style
            Expanded(
              flex: 3,
              child: Text(
                tx.invoiceId,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.teal600,
                ),
              ),
            ),

            // Customer
            Expanded(
              flex: 4,
              child: Text(tx.customer,
                  style: AppTextStyles.body.copyWith(color: AppColors.gray700)),
            ),

            // Items
            Expanded(
              flex: 2,
              child: Center(
                child: Text('${tx.items}',
                    style: AppTextStyles.bodyBold),
              ),
            ),

            // Payment method chip
            Expanded(
              flex: 3,
              child: Center(child: _PaymentChip(tx.payment)),
            ),

            // Amount
            Expanded(
              flex: 3,
              child: Text(
                '₹${tx.amount.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900),
              ),
            ),

            // Status badge
            Expanded(
              flex: 2,
              child: Center(child: _StatusBadge(tx.status)),
            ),

            // Actions
            Expanded(
              flex: 2,
              child: AnimatedOpacity(
                opacity: _hov ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _IconAction(
                      icon: Icons.visibility_outlined,
                      tooltip: 'View Details',
                      onTap: () {},
                    ),
                    const SizedBox(width: 4),
                    _IconAction(
                      icon: Icons.print_outlined,
                      tooltip: 'Print Bill',
                      onTap: () {},
                    ),
                    if (tx.status != TxStatus.refunded) ...[
                      const SizedBox(width: 4),
                      _IconAction(
                        icon: Icons.undo_outlined,
                        tooltip: 'Refund',
                        color: AppColors.red500,
                        onTap: () {},
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment chip ──────────────────────────────────────────────────────────────
class _PaymentChip extends StatelessWidget {
  final TxPayment method;
  const _PaymentChip(this.method);

  @override
  Widget build(BuildContext context) {
    final configs = {
      TxPayment.upi:  (label: 'UPI',  bg: const Color(0xFFEDE9FE), fg: const Color(0xFF6D28D9)),
      TxPayment.card: (label: 'Card', bg: const Color(0xFFE0F2FE), fg: const Color(0xFF0369A1)),
      TxPayment.cash: (label: 'Cash', bg: const Color(0xFFFEF9C3), fg: const Color(0xFF92400E)),
    };
    final cfg = configs[method]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(cfg.label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cfg.fg)),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final TxStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final configs = {
      TxStatus.completed: (label: 'Completed', bg: AppColors.green100,              fg: AppColors.green700),
      TxStatus.refunded:  (label: 'Refunded',  bg: AppColors.red100,               fg: AppColors.red700),
      TxStatus.pending:   (label: 'Pending',   bg: const Color(0xFFFEF9C3),        fg: const Color(0xFF92400E)),
    };
    final cfg = configs[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(cfg.label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cfg.fg)),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────
class _TH extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;
  const _TH(this.text, {this.flex = 1, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(text,
          textAlign: align,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.gray500,
              letterSpacing: 0.5)),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final double width;
  const _FilterDropdown(
      {required this.value, required this.items, required this.onChanged, this.width = 150});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e,
                  style: const TextStyle(fontSize: 13, color: AppColors.gray700),
                  overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
          style: AppTextStyles.body,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 16, color: AppColors.gray500),
        ),
      ),
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = AppColors.gray500,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
              color: _hov ? widget.color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon, size: 16,
                color: _hov ? widget.color : AppColors.gray400),
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final int current;
  final int total;
  final ValueChanged<int> onChanged;
  const _PaginationBar(
      {required this.current, required this.total, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(total.clamp(1, 5), (i) => i + 1);
    return Row(
      children: [
        _PgBtn(
          icon: Icons.chevron_left,
          onTap: current > 1 ? () => onChanged(current - 1) : null,
        ),
        ...pages.map((p) => _PgNum(
          number: p,
          active: current == p,
          onTap: () => onChanged(p),
        )),
        _PgBtn(
          icon: Icons.chevron_right,
          onTap: current < total ? () => onChanged(current + 1) : null,
        ),
      ],
    );
  }
}

class _PgBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _PgBtn({required this.icon, this.onTap});

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
          child: Icon(icon, size: 18,
              color: onTap == null ? AppColors.gray300 : AppColors.gray600),
        ),
      ),
    );
  }
}

class _PgNum extends StatelessWidget {
  final int number;
  final bool active;
  final VoidCallback onTap;
  const _PgNum({required this.number, required this.active, required this.onTap});

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
            color: active ? AppColors.teal600 : AppColors.white,
            border: Border.all(
                color: active ? AppColors.teal600 : AppColors.gray300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text('$number',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.white : AppColors.gray700)),
          ),
        ),
      ),
    );
  }
}