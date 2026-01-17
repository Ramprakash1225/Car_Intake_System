import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class TNMarketKingsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _marketKings = [];
  bool _isLoading = false;
  String? _error;
  bool _isUsingFallbackData = false;
  static const String _cacheKey = 'tn_market_kings_cache';
  static const String _cacheTimestampKey = 'tn_market_kings_cache_timestamp';

  List<Map<String, dynamic>> get marketKings => _marketKings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsingFallbackData => _isUsingFallbackData;

  TNMarketKingsProvider() {
    // Load cached data on initialization
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> cachedList = json.decode(cachedJson);
        _marketKings = cachedList.map((item) => Map<String, dynamic>.from(item)).toList();
        _isUsingFallbackData = false;
        debugPrint('Loaded ${_marketKings.length} TN market kings from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached TN market kings: $e');
    }
  }

  Future<void> _saveToCache(List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      debugPrint('Saved TN market kings to cache');
    } catch (e) {
      debugPrint('Error saving TN market kings to cache: $e');
    }
  }

  Future<void> loadTNMarketKings({bool forceRefresh = false}) async {
    // If we already have data in memory and not forcing refresh, don't reload
    if (!forceRefresh && _marketKings.isNotEmpty && !_isLoading) {
      return;
    }

    // If not forcing refresh, try to load from cache first
    if (!forceRefresh && _marketKings.isEmpty) {
      await _loadCachedData();
      // If we have cached data, use it and don't call AI
      if (_marketKings.isNotEmpty) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    _isUsingFallbackData = false;
    notifyListeners();

    try {
      debugPrint('Loading Tamil Nadu Market Kings from Gemini AI...');
      final kings = await AIService.generateTNMarketKings(forceRefresh: forceRefresh);
      
      if (kings.isNotEmpty) {
        _marketKings = kings;
        _isUsingFallbackData = false;
        await _saveToCache(kings);
        debugPrint('Successfully loaded ${kings.length} TN market kings from Gemini AI and saved to cache');
      } else {
        // If AI returned empty, use fallback
        _marketKings = AIService.getDefaultTNMarketKings();
        _isUsingFallbackData = true;
        debugPrint('AI returned empty, using fallback data');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading TN market kings: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      // Use fallback data on error
      _marketKings = AIService.getDefaultTNMarketKings();
      _isUsingFallbackData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

