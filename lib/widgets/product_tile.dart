import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_colors_ext.dart';

enum StockStatus { inStock, lowStock, outOfStock }

class ProductTileData {
  final String id, name, barcode, category;
  final double price;
  final int stock;
  const ProductTileData({required this.id, required this.name, required this.barcode,
    required this.category, required this.price, required this.stock});
  StockStatus get status => stock == 0 ? StockStatus.outOfStock
      : stock <= 5 ? StockStatus.lowStock : StockStatus.inStock;
}

class ProductTile extends StatefulWidget {
  final ProductTileData product;
  final int index;
  final VoidCallback? onEdit, onDelete;
  const ProductTile({super.key, required this.product, required this.index,
    this.onEdit, this.onDelete});
  @override State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _hov = false;

  Color _statusBg()   { switch(widget.product.status) { case StockStatus.inStock: return AppColors.green100; case StockStatus.lowStock: return AppColors.orange100; case StockStatus.outOfStock: return AppColors.red100; } }
  Color _statusFg()   { switch(widget.product.status) { case StockStatus.inStock: return AppColors.green700; case StockStatus.lowStock: return AppColors.orange700; case StockStatus.outOfStock: return AppColors.red700; } }
  String _statusLbl() { switch(widget.product.status) { case StockStatus.inStock: return 'In Stock'; case StockStatus.lowStock: return 'Low Stock'; case StockStatus.outOfStock: return 'Out of Stock'; } }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hov ? c.rowHover : c.cardBg,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.product.name, style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600, color: c.textPrimary)),
            const SizedBox(height: 2),
            Text(widget.product.category, style: TextStyle(fontSize: 12, color: c.textMuted)),
          ])),
          Expanded(flex: 2, child: Text(widget.product.barcode,
              style: TextStyle(fontSize: 13, fontFamily: 'monospace', color: c.textSub))),
          SizedBox(width: 110, child: Text('₹${widget.product.price.toStringAsFixed(2)}',
              textAlign: TextAlign.right, style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600, color: c.textPrimary))),
          SizedBox(width: 80, child: Text('${widget.product.stock}',
              textAlign: TextAlign.right, style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.product.stock == 0 ? AppColors.red500 : c.textPrimary))),
          SizedBox(width: 120, child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: _statusBg(), borderRadius: BorderRadius.circular(20)),
            child: Text(_statusLbl(), style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w700, color: _statusFg())),
          ))),
          SizedBox(width: 80, child: AnimatedOpacity(
            opacity: _hov ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _ABtn(Icons.edit_outlined, AppColors.teal600, widget.onEdit ?? (){}),
              const SizedBox(width: 4),
              _ABtn(Icons.delete_outline, AppColors.red500, widget.onDelete ?? (){}),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _ABtn extends StatefulWidget {
  final IconData icon; final Color color; final VoidCallback onTap;
  const _ABtn(this.icon, this.color, this.onTap);
  @override State<_ABtn> createState() => _ABtnState();
}
class _ABtnState extends State<_ABtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hov = true),
    onExit:  (_) => setState(() => _hov = false),
    cursor: SystemMouseCursors.click,
    child: GestureDetector(onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: _hov ? widget.color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(widget.icon, size: 17, color: _hov ? widget.color : context.colors.textMuted),
      ),
    ),
  );
}