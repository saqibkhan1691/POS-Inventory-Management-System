import '../database/dao/product_dao.dart';
import '../models/product_model.dart';

/// ─────────────────────────────────────────────────────────────
///  PRODUCT REPOSITORY  –  lib/repositories/product_repository.dart
///  Business logic layer between screens and DAO.
///  Screens ONLY call this — never the DAO directly.
/// ─────────────────────────────────────────────────────────────
class ProductRepository {
  final _dao = ProductDao();

  // ── ADD ────────────────────────────────────────────────────
  Future<int> addProduct({
    required String name,
    required String barcode,
    required String category,
    String   brand         = 'In-House',
    required double purchasePrice,
    required double sellingPrice,
    double   taxRate       = 0.05,
    int      stock         = 0,
    int      alertQty      = 5,
    String   barcodeType   = 'CODE128',
    String?  description,
  }) async {
    final now = DateTime.now();
    final product = ProductModel(
      name:          name,
      barcode:       barcode,
      category:      category,
      brand:         brand,
      purchasePrice: purchasePrice,
      sellingPrice:  sellingPrice,
      taxRate:       taxRate,
      stock:         stock,
      alertQty:      alertQty,
      barcodeType:   barcodeType,
      description:   description,
      createdAt:     now,
      updatedAt:     now,
    );
    return _dao.insert(product);
  }

  // ── GET ALL ────────────────────────────────────────────────
  Future<List<ProductModel>> getAllProducts() => _dao.getAll();

  // ── SCAN BARCODE (used in billing) ─────────────────────────
  Future<ProductModel?> findByBarcode(String barcode) =>
      _dao.getByBarcode(barcode);

  // ── SEARCH ─────────────────────────────────────────────────
  Future<List<ProductModel>> search(String query) =>
      query.trim().isEmpty ? _dao.getAll() : _dao.search(query);

  // ── FILTER ─────────────────────────────────────────────────
  Future<List<ProductModel>> getByCategory(String category) =>
      category == 'All Categories'
          ? _dao.getAll()
          : _dao.getByCategory(category);

  // ── CATEGORIES ─────────────────────────────────────────────
  Future<List<String>> getCategories() => _dao.getCategories();

  // ── LOW STOCK ──────────────────────────────────────────────
  Future<List<ProductModel>> getLowStock() => _dao.getLowStock();

  // ── UPDATE ─────────────────────────────────────────────────
  Future<void> updateProduct(ProductModel product) => _dao.update(product);

  // ── DECREASE STOCK after sale ──────────────────────────────
  Future<void> decreaseStock(int productId, int qty) =>
      _dao.adjustStock(productId, -qty);

  // ── DELETE ─────────────────────────────────────────────────
  Future<void> deleteProduct(int id) => _dao.delete(id);

  // ── COUNT ──────────────────────────────────────────────────
  Future<int> count() => _dao.count();
}