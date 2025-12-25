// lib/services/favorites_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/favorite_vendor.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_vendors';

  // Add vendor to favorites
  static Future<void> addFavorite(FavoriteVendor vendor) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    // Check if already exists
    if (!favorites.any((v) => v.vendorId == vendor.vendorId)) {
      favorites.add(vendor);
      final jsonList = favorites.map((v) => json.encode(v.toMap())).toList();
      await prefs.setStringList(_favoritesKey, jsonList);
    }
  }

  // Remove vendor from favorites
  static Future<void> removeFavorite(String vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((v) => v.vendorId == vendorId);
    
    final jsonList = favorites.map((v) => json.encode(v.toMap())).toList();
    await prefs.setStringList(_favoritesKey, jsonList);
  }

  // Get all favorites
  static Future<List<FavoriteVendor>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_favoritesKey) ?? [];
    
    return jsonList
        .map((jsonStr) => FavoriteVendor.fromMap(json.decode(jsonStr)))
        .toList();
  }

  // Check if vendor is favorite
  static Future<bool> isFavorite(String vendorId) async {
    final favorites = await getFavorites();
    return favorites.any((v) => v.vendorId == vendorId);
  }

  // Toggle favorite
  static Future<bool> toggleFavorite(FavoriteVendor vendor) async {
    final isFav = await isFavorite(vendor.vendorId);
    if (isFav) {
      await removeFavorite(vendor.vendorId);
      return false;
    } else {
      await addFavorite(vendor);
      return true;
    }
  }
}
