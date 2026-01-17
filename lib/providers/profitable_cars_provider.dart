import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class ProfitableCarsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _threeYearsCars = [];
  List<Map<String, dynamic>> _fiveYearsCars = [];
  List<Map<String, dynamic>> _tenYearsCars = [];
  bool _isLoading = false;
  String? _error;
  bool _isUsingFallbackData = false;
  static const String _cacheKey = 'profitable_cars_cache';
  static const String _cacheTimestampKey = 'profitable_cars_cache_timestamp';

  List<Map<String, dynamic>> get threeYearsCars => _threeYearsCars;
  List<Map<String, dynamic>> get fiveYearsCars => _fiveYearsCars;
  List<Map<String, dynamic>> get tenYearsCars => _tenYearsCars;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsingFallbackData => _isUsingFallbackData;

  ProfitableCarsProvider() {
    // Load cached data on initialization
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> cachedData = json.decode(cachedJson);
        _threeYearsCars = (cachedData['threeYears'] as List?)
                ?.map((item) => Map<String, dynamic>.from(item))
                .toList() ??
            [];
        _fiveYearsCars = (cachedData['fiveYears'] as List?)
                ?.map((item) => Map<String, dynamic>.from(item))
                .toList() ??
            [];
        _tenYearsCars = (cachedData['tenYears'] as List?)
                ?.map((item) => Map<String, dynamic>.from(item))
                .toList() ??
            [];
        _isUsingFallbackData = false;
        debugPrint('Loaded profitable cars from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached profitable cars: $e');
    }
  }

  Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      debugPrint('Saved profitable cars to cache');
    } catch (e) {
      debugPrint('Error saving profitable cars to cache: $e');
    }
  }

  Future<void> loadProfitableCars({bool forceRefresh = false}) async {
    // If we already have data in memory and not forcing refresh, don't reload
    if (!forceRefresh && _threeYearsCars.isNotEmpty && _fiveYearsCars.isNotEmpty && _tenYearsCars.isNotEmpty && !_isLoading) {
      return;
    }

    // If not forcing refresh, try to load from cache first
    if (!forceRefresh && _threeYearsCars.isEmpty && _fiveYearsCars.isEmpty && _tenYearsCars.isEmpty) {
      await _loadCachedData();
      // If we have cached data, use it and don't call AI
      if (_threeYearsCars.isNotEmpty || _fiveYearsCars.isNotEmpty || _tenYearsCars.isNotEmpty) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    _isUsingFallbackData = false;
    notifyListeners();

    try {
      debugPrint('Loading profitable cars from Gemini AI...');
      final cars = await AIService.generateProfitableCars(forceRefresh: forceRefresh);
      
      if (cars['threeYears'] != null && cars['fiveYears'] != null && cars['tenYears'] != null) {
        _threeYearsCars = cars['threeYears'] ?? [];
        _fiveYearsCars = cars['fiveYears'] ?? [];
        _tenYearsCars = cars['tenYears'] ?? [];
        _isUsingFallbackData = false;
        await _saveToCache(cars);
        debugPrint('Successfully loaded profitable cars from Gemini AI and saved to cache');
      } else {
        // If AI returned empty, use fallback
        final fallbackData = AIService.getDefaultProfitableCars();
        _threeYearsCars = fallbackData['threeYears'] ?? [];
        _fiveYearsCars = fallbackData['fiveYears'] ?? [];
        _tenYearsCars = fallbackData['tenYears'] ?? [];
        _isUsingFallbackData = true;
        debugPrint('AI returned empty, using fallback data');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading profitable cars: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      // Use fallback data on error
      final fallbackData = AIService.getDefaultProfitableCars();
      _threeYearsCars = fallbackData['threeYears'] ?? [];
      _fiveYearsCars = fallbackData['fiveYears'] ?? [];
      _tenYearsCars = fallbackData['tenYears'] ?? [];
      _isUsingFallbackData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

