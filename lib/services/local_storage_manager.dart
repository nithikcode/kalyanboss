import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/helpers/helpers.dart';

class LocalStorageManager {
  LocalStorageManager._internal();

  static final LocalStorageManager _instance = LocalStorageManager._internal();
  static LocalStorageManager get instance => _instance;

  final storage = const FlutterSecureStorage();

  String? productList;
  String? cartLead;
  String? pinCode;
  String? cartProductList;
  String? cartQuantityList;

  /// Stream controllers for reactive updates
  final StreamController<List<String>> _recentlyViewedController =
  StreamController<List<String>>.broadcast();

  final StreamController<List<String>> _cartLeadController =
  StreamController<List<String>>.broadcast();

  final StreamController<List<String>> _cartProductsController =
  StreamController<List<String>>.broadcast();

  /// : Pincode stream controller (String? because it can be null)
  final StreamController<String?> _pinCodeController =
  StreamController<String?>.broadcast();

  /// : Recent searches stream controller
  final StreamController<List<dynamic>> _recentSearchController =
  StreamController<List<String>>.broadcast();

  // Streams
  Stream<List<String>> get recentlyViewedStream =>
      _recentlyViewedController.stream;
  Stream<List<String>> get cartProductsStream =>
      _cartProductsController.stream;
  Stream<String?> get pinCodeStream => _pinCodeController.stream;
  Stream<List<dynamic>> get recentSearchStream => _recentSearchController.stream;
  Stream<List<String>> get cartLeadStream => _cartLeadController.stream;

  /// Expose controllers to extensions
  StreamController<List<String>> get recentlyViewedController =>
      _recentlyViewedController;
  StreamController<List<String>> get cartProductsController =>
      _cartProductsController;
  StreamController<String?> get pinCodeController => _pinCodeController;
  StreamController<List<dynamic>> get recentSearchController =>
      _recentSearchController;
  StreamController<List<String>> get cartLeadController =>
      _cartLeadController;

  /// Dispose controllers when app closes
  void dispose() {
    _recentlyViewedController.close();
    _cartProductsController.close();
    _pinCodeController.close();
    _recentSearchController.close();
  }
}

extension CartManager on LocalStorageManager {
  /// Save or update a product with quantity
  Future<void> addOrUpdateCartProduct(String productId, String quantity) async {
    final products = await getCartProducts();
    final quantities = await getCartQuantities();

    final index = products.indexOf(productId);

    if (index == -1) {
      // Add new
      products.add(productId);
      quantities.add(quantity);
    } else {
      // Update quantity
      quantities[index] = quantity;
    }

    await _saveCart(products, quantities);
    createLog("Saved to Local Cart $cartProductList");
    createLog("Saved to Local Cart $cartQuantityList");
  }

  /// Remove product by id
  Future<void> removeCartProduct(String productId) async {
    final products = await getCartProducts();
    final quantities = await getCartQuantities();

    final index = products.indexOf(productId);
    if (index != -1) {
      products.removeAt(index);
      quantities.removeAt(index);
    }

    await _saveCart(products, quantities);
  }

  /// Save cart (internal helper)
  Future<void> _saveCart(List<String> products, List<String> quantities) async {
    final productsString = products.join(",");
    final quantitiesString = quantities.join(",");

    await storage.write(key: "cartProducts", value: productsString);
    await storage.write(key: "cartQuantities", value: quantitiesString);

    cartProductList = productsString;
    cartQuantityList = quantitiesString;
    _cartProductsController.add(products);

  }

  /// Get cart products
  Future<List<String>> getCartProducts() async {
    final value = await storage.read(key: "cartProducts");
    if (value == null || value.isEmpty) return [];
    return value.split(",");
  }

  /// Get cart quantities
  Future<List<String>> getCartQuantities() async {
    final value = await storage.read(key: "cartQuantities");
    if (value == null || value.isEmpty) return [];
    return value.split(",");
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    await storage.delete(key: "cartProducts");
    await storage.delete(key: "cartQuantities");
    cartProductList = null;
    _cartProductsController.add([]);
  }

  /// Generate payload for API
  Future<Map<String, String>> getCartPayload() async {
    final products = await getCartProducts();
    final quantities = await getCartQuantities();

    return {
      "product_ids": products.join(","),
      "quantities": quantities.join(","),
    };
  }
}

extension RecentSearchManager on LocalStorageManager {
  static const String _recentSearchKey = "recentSearches";
  static const int _maxRecentSearches = 5;

  Future<void> addRecentSearch(String search) async {
    final searches = await getRecentSearches();

    searches.remove(search);
    searches.insert(0, search);

    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }

    await _saveRecentSearches(searches);
    _recentSearchController.add(searches);
    createLog("Saved recent searches: $searches");
  }

  Future<void> removeRecentSearch(String search) async {
    final searches = await getRecentSearches();
    searches.remove(search);
    await _saveRecentSearches(searches);
    _recentSearchController.add(searches);
    createLog("Removed '$search' from recent searches: $searches");
  }

  Future<List<String>> getRecentSearches() async {
    final value = await storage.read(key: _recentSearchKey);

    // Safely convert to List<String>
    final searches = (value == null || value.isEmpty)
        ? <String>[]
        : value.split(",").map((e) => e.toString()).toList();

    // Emit to stream so StreamBuilder updates
    _recentSearchController.add(searches);

    return searches;
  }


  Future<void> clearRecentSearches() async {
    await storage.delete(key: _recentSearchKey);
    _recentSearchController.add([]);
    createLog("Cleared all recent searches");
  }


  Future<void> _saveRecentSearches(List<String> searches) async {
    await storage.write(key: _recentSearchKey, value: searches.join(","));
    _recentSearchController.add(searches);
  }
}

extension PinCodeManager on LocalStorageManager {
  static const String _pinCodeKey = "pinCode";

  /// Save pincode to secure storage and broadcast to stream
  Future<void> savePinCode(String pinCode) async {
    this.pinCode = pinCode;
    await storage.write(key: _pinCodeKey, value: pinCode);

    // CRITICAL FIX: Broadcast the change to all listeners
    _pinCodeController.add(pinCode);

    createLog("Saved pincode: $pinCode");
  }

  /// Get pincode from storage
  Future<String?> getPinCode() async {
    pinCode = await storage.read(key: _pinCodeKey);
    return pinCode;
  }

  /// Clear saved pincode and broadcast null to stream
  Future<void> clearPinCode() async {
    pinCode = null;
    await storage.delete(key: _pinCodeKey);

    // CRITICAL FIX: Broadcast null to notify listeners of the clear
    _pinCodeController.add(null);

    createLog("Cleared pincode");
  }
}

extension RecentlyViewedManager on LocalStorageManager {
  static const String _recentlyViewedKey = "recentlyViewedProducts";
  static const int _maxRecentlyViewed = 10;

  /// Save new product IDs to recently viewed (keeps max 10, most recent first)
  Future<void> saveToRecentlyViewed(List<String> newProductIds) async {
    final existingIdsString = await storage.read(key: _recentlyViewedKey);
    final existingIds = existingIdsString?.split(',') ?? [];

    // New first, then existing
    final combined = [...newProductIds, ...existingIds];

    // Remove duplicates (preserve first occurrence order)
    final seen = <String>{};
    final uniqueIds = combined.where((id) => seen.add(id)).toList();

    // Limit to max allowed
    final limitedIds = uniqueIds.take(_maxRecentlyViewed).toList();

    final joined = limitedIds.join(',');
    productList = joined;
    await storage.write(key: _recentlyViewedKey, value: joined);

    _recentlyViewedController.add(limitedIds);
    createLog("Recently viewed saved: $limitedIds");
  }

  /// Get recently viewed product IDs
  Future<List<String>> getRecentlyViewed() async {
    final value = await storage.read(key: _recentlyViewedKey);
    if (value == null || value.isEmpty) return [];
    productList = value;
    return value.split(',');
  }

  /// Clear recently viewed products
  Future<void> clearRecentlyViewed() async {
    productList = null;
    await storage.delete(key: _recentlyViewedKey);
    _recentlyViewedController.add([]);
    createLog("Recently viewed cleared");
  }
}

extension LeadManager on LocalStorageManager {
  static const String _cartLeadKey = "CartLead";
  static const int _maxCartLead = 1;

  /// Save new product IDs to recently viewed (keeps max 10, most recent first)
  Future<void> saveToLocalCartLead(List<String> newProductIds) async {
    final existingIdsString = await storage.read(key: _cartLeadKey);
    final existingIds = existingIdsString?.split(',') ?? [];

    // New first, then existing
    final combined = [...newProductIds, ...existingIds];

    // Remove duplicates (preserve first occurrence order)
    final seen = <String>{};
    final uniqueIds = combined.where((id) => seen.add(id)).toList();

    // Limit to max allowed
    final limitedIds = uniqueIds.take(_maxCartLead).toList();

    final joined = limitedIds.join(',');
    cartLead = joined;
    await storage.write(key: _cartLeadKey, value: joined);

    _cartLeadController.add(limitedIds);
    createLog("Cart Lead saved: $limitedIds");
  }

  /// Get recently viewed product IDs
  Future<List<String>> getCartLead() async {
    final value = await storage.read(key: _cartLeadKey);
    if (value == null || value.isEmpty) return [];
    cartLead = value;
    return value.split(',');
  }

  /// Clear recently viewed products
  Future<void> clearCartLead() async {
    cartLead = null;
    await storage.delete(key: _cartLeadKey);
    _cartLeadController.add([]);
    createLog("cart Lead cleared");
  }
}
