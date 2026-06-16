import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';

/// CartItem now carries maxStock — the available stock at time of adding.
class CartItem {
  final String id, barcode, name;
  final double price;
  int qty;
  final int maxStock;
  CartItem({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    this.qty = 1,
    this.maxStock = 9999,
  });
  double get total => price * qty;
}

class CartList extends StatelessWidget {
  final List<CartItem> items;
  final ValueChanged<CartItem> onIncrease, onDecrease, onRemove, onAddTen, onResetQty;
  const CartList({
    super.key,
    required this.items,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onAddTen,
    required this.onResetQty,
  });

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
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: c.tableHeader,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border(bottom: BorderSide(color: c.border)),
          ),
          child: Row(children: [
            SizedBox(width: 36, child: Text('#', style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w700, color: c.textSub, letterSpacing: 0.5))),
            Expanded(flex: 5, child: _TH('Product Details', c)),
            SizedBox(width: 180, child: _TH('Qty', c, center: true)),
            SizedBox(width: 110, child: _TH('Price', c, right: true)),
            SizedBox(width: 120, child: _TH('Total', c, right: true)),
            const SizedBox(width: 48),
          ]),
        ),
        // Rows
        Expanded(
          child: items.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.qr_code_scanner_outlined, size: 56, color: c.textMuted),
            const SizedBox(height: 12),
            Text('Cart is empty. Scan products to add.',
                style: TextStyle(fontSize: 14, color: c.textMuted)),
          ]))
              : ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: c.borderLight),
            itemBuilder: (ctx, i) => _CartRow(
              index: i + 1, item: items[i],
              onIncrease: () => onIncrease(items[i]),
              onDecrease: () => onDecrease(items[i]),
              onRemove:   () => onRemove(items[i]),
              onAddTen:   () => onAddTen(items[i]),
              onResetQty: () => onResetQty(items[i]),
            ),
          ),
        ),
      ]),
    );
  }
}

Widget _TH(String text, AdaptiveColors c, {bool center = false, bool right = false}) =>
    Text(text,
        textAlign: right ? TextAlign.right : center ? TextAlign.center : TextAlign.left,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: c.textSub, letterSpacing: 0.5));

class _CartRow extends StatefulWidget {
  final int index;
  final CartItem item;
  final VoidCallback onIncrease, onDecrease, onRemove, onAddTen, onResetQty;
  const _CartRow({
    required this.index, required this.item,
    required this.onIncrease, required this.onDecrease, required this.onRemove,
    required this.onAddTen, required this.onResetQty,
  });
  @override State<_CartRow> createState() => _CartRowState();
}

class _CartRowState extends State<_CartRow> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final atMax = widget.item.qty >= widget.item.maxStock;

    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hov ? c.rowHover : c.cardBg,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          SizedBox(width: 36, child: Text('${widget.index}',
              style: TextStyle(fontSize: 12, color: c.textMuted))),
          Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.item.name, style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600, color: c.textPrimary)),
            const SizedBox(height: 2),
            Row(children: [
              Text(widget.item.barcode, style: TextStyle(fontSize: 11,
                  fontFamily: 'monospace', color: c.textMuted)),
              if (atMax) ...[
                const SizedBox(width: 8),
                Text('Max stock reached',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: AppColors.orange700)),
              ],
            ]),
          ])),
          // ── Qty controls ─────────────────────────────────
          SizedBox(width: 180, child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(color: c.inputFill,
                    borderRadius: BorderRadius.circular(7), border: Border.all(color: c.border)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  _QBtn(Icons.remove, widget.onDecrease, c),
                  SizedBox(width: 32, child: Center(child: Text('${widget.item.qty}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: c.textPrimary)))),
                  _QBtn(Icons.add, atMax ? null : widget.onIncrease, c, disabled: atMax),
                ]),
              ),
              const SizedBox(height: 6),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _Chip('+10', atMax ? null : widget.onAddTen, c),
                const SizedBox(width: 6),
                _IconChip(Icons.restart_alt, widget.item.qty > 1 ? widget.onResetQty : null,
                    c, tooltip: 'Reset to 1'),
              ]),
            ],
          ))),
          SizedBox(width: 110, child: Text('₹${widget.item.price.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: c.textSecond))),
          SizedBox(width: 120, child: Text('₹${widget.item.total.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.textPrimary))),
          SizedBox(width: 48, child: AnimatedOpacity(
            opacity: _hov ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: IconButton(onPressed: widget.onRemove,
                icon: const Icon(Icons.delete_outline, size: 20),
                color: c.textMuted,
                hoverColor: AppColors.red50,
                style: IconButton.styleFrom(foregroundColor: AppColors.red500)),
          )),
        ]),
      ),
    );
  }
}

// ── Small reusable controls ───────────────────────────────────
class _QBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final AdaptiveColors c;
  final bool disabled;
  const _QBtn(this.icon, this.onTap, this.c, {this.disabled = false});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(5),
    child: Padding(padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: disabled ? c.textMuted : c.textSecond)),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AdaptiveColors c;
  const _Chip(this.label, this.onTap, this.c);
  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: disabled ? c.inputFill : AppColors.teal50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: disabled ? c.border : AppColors.teal100),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: disabled ? c.textMuted : AppColors.teal700)),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final AdaptiveColors c;
  final String? tooltip;
  const _IconChip(this.icon, this.onTap, this.c, {this.tooltip});
  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final btn = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: disabled ? c.inputFill : c.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Icon(icon, size: 13, color: disabled ? c.textMuted : c.textSecond),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}