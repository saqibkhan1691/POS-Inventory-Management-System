import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  CART LIST  –  Scrollable table of products in the bill
///  Used in: BillingScreen (center)
/// ─────────────────────────────────────────────────────────────

// Lightweight cart item data class (no business logic)
class CartItem {
  final String id;
  final String barcode;
  final String name;
  final double price;
  int qty;

  CartItem({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    this.qty = 1,
  });

  double get total => price * qty;
}

class CartList extends StatelessWidget {
  final List<CartItem> items;
  final ValueChanged<CartItem> onIncrease;
  final ValueChanged<CartItem> onDecrease;
  final ValueChanged<CartItem> onRemove;

  const CartList({
    super.key,
    required this.items,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        children: [
          // ── Table header ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 36,  child: _HeaderCell('#',       align: TextAlign.left)),
                Expanded(flex: 5,    child: _HeaderCell('Product Details')),
                SizedBox(width: 120, child: _HeaderCell('Qty',     align: TextAlign.center)),
                SizedBox(width: 110, child: _HeaderCell('Price',   align: TextAlign.right)),
                SizedBox(width: 120, child: _HeaderCell('Total',   align: TextAlign.right)),
                SizedBox(width: 48),
              ],
            ),
          ),

          // ── Rows ─────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? _emptyState()
                : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppColors.gray100),
              itemBuilder: (ctx, i) => _CartRow(
                index: i + 1,
                item: items[i],
                onIncrease: () => onIncrease(items[i]),
                onDecrease: () => onDecrease(items[i]),
                onRemove:   () => onRemove(items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner_outlined, size: 56, color: AppColors.gray300),
          const SizedBox(height: 12),
          Text('Cart is empty. Scan products to add.',
              style: AppTextStyles.body.copyWith(color: AppColors.gray400)),
        ],
      ),
    );
  }
}

// ── Header cell ───────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String text;
  final TextAlign align;
  const _HeaderCell(this.text, {this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: AppTextStyles.captionBold,
    );
  }
}

// ── Cart row ──────────────────────────────────────────────────────────────────
class _CartRow extends StatefulWidget {
  final int index;
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartRow({
    required this.index,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  State<_CartRow> createState() => _CartRowState();
}

class _CartRowState extends State<_CartRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hovered ? AppColors.slate50 : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Index
            SizedBox(
              width: 36,
              child: Text('${widget.index}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.gray500)),
            ),

            // Product name + barcode
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.name, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(widget.item.barcode,
                      style: AppTextStyles.mono.copyWith(fontSize: 11)),
                ],
              ),
            ),

            // Qty stepper
            SizedBox(
              width: 120,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: widget.onDecrease),
                      Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.item.qty}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gray800),
                        ),
                      ),
                      _QtyButton(icon: Icons.add, onTap: widget.onIncrease),
                    ],
                  ),
                ),
              ),
            ),

            // Unit price
            SizedBox(
              width: 110,
              child: Text(
                '₹${widget.item.price.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(color: AppColors.gray700),
              ),
            ),

            // Line total
            SizedBox(
              width: 120,
              child: Text(
                '₹${widget.item.total.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gray900),
              ),
            ),

            // Remove button
            SizedBox(
              width: 48,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _hovered ? 1.0 : 0.0,
                child: IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.gray400,
                  hoverColor: AppColors.red50,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.red500,
                  ),
                  tooltip: 'Remove',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: AppColors.gray600),
      ),
    );
  }
}
