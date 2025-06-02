import 'package:flutter/foundation.dart' as foundation;
import 'package:wallet_watchers_app/models/category.dart';
import 'package:wallet_watchers_app/services/api_service.dart';

class CategoriesProvider with foundation.ChangeNotifier {
  final ApiService _apiService;
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoriesProvider(this._apiService);

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _apiService.getAllCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.categoryName.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
} 