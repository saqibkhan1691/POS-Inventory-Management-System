import 'package:flutter/material.dart';
import '../core/theme.dart';

/// ─────────────────────────────────────────────────────────────
///  PRODUCT TILE  –  Inventory row with status badge + actions
///  Used in: InventoryScreen table
/// ─────────────────────────────────────────────────────────────

enum StockStatus { inStock, lowStock, outOfStock }

class ProductTileData {
  final String id;
  final String name;
  final String barcode;
  final String category;
  final double price;
  final int    stock;

  const ProductTileData({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.price,
    required this.stock,
  });

  StockStatus get status {
    if (stock == 0) return StockStatus.outOfStock;
    if (stock <= 5) return StockStatus.lowStock;
    return StockStatus.inStock;
  }
}

class ProductTile extends StatefulWidget {
  final ProductTileData product;
  final int index;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductTile({
    super.key,
    required this.product,
    required this.index,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _hovered = false;

  Color get _statusColor {
    switch (widget.product.status) {
      case StockStatus.inStock:    return AppColors.green100;
      case StockStatus.lowStock:   return AppColors.orange100;
      case StockStatus.outOfStock: return AppColors.red100;
    }
  }

  Color get _statusTextColor {
    switch (widget.product.status) {
      case StockStatus.inStock:    return AppColors.green700;
      case StockStatus.lowStock:   return AppColors.orange700;
      case StockStatus.outOfStock: return AppColors.red700;
    }
  }

  String get _statusLabel {
    switch (widget.product.status) {
      case StockStatus.inStock:    return 'In Stock';
      case StockStatus.lowStock:   return 'Low Stock';
      case StockStatus.outOfStock: return 'Out of Stock';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _hovered ? AppColors.slate50 : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Product name + category
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.name, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(widget.product.category, style: AppTextStyles.caption),
                ],
              ),
            ),

            // Barcode
            Expanded(
              flex: 2,
              child: Text(
                widget.product.barcode,
                style: AppTextStyles.mono,
              ),
            ),

            // Price
            SizedBox(
              width: 110,
              child: Text(
                '₹${widget.product.price.toStringAsFixed(2)}',
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyBold.copyWith(color: AppColors.gray900),
              ),
            ),

            // Stock qty
            SizedBox(
              width: 80,
              child: Text(
                '${widget.product.stock}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.product.stock == 0
                      ? AppColors.red500
                      : AppColors.gray900,
                ),
              ),
            ),

            // Status badge
            SizedBox(
              width: 120,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusTextColor,
                    ),
                  ),
                ),
              ),
            ),

            // Actions
            SizedBox(
              width: 80,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _hovered ? 1.0 : 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionBtn(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit',
                      hoverColor: AppColors.teal600,
                      onTap: widget.onEdit ?? () {},
                    ),
                    const SizedBox(width: 4),
                    _ActionBtn(
                      icon: Icons.delete_outline,
                      tooltip: 'Delete',
                      hoverColor: AppColors.red500,
                      onTap: widget.onDelete ?? () {},
                    ),
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

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color hoverColor;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.tooltip, required this.hoverColor, required this.onTap});

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hov = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _hov ? widget.hoverColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 17,
              color: _hov ? widget.hoverColor : AppColors.gray400,
            ),
          ),
        ),
      ),
    );
  }
}
