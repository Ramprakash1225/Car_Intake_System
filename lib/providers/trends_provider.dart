import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import 'ai_usage_provider.dart';

class TrendsProvider with ChangeNotifier {
  AIUsageProvider? _aiUsageProvider;

  void setAIUsageProvider(AIUsageProvider provider) {
    _aiUsageProvider = provider;
  }

  List<Map<String, dynamic>> _trends = [];
  bool _isLoading = false;
  String? _error;
  bool _isUsingFallbackData = false;
  static const String _cacheKey = 'trends_cache';
  static const String _cacheTimestampKey = 'trends_cache_timestamp';

  List<Map<String, dynamic>> get trends => _trends;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsingFallbackData => _isUsingFallbackData;

  TrendsProvider() {
    // Load cached data on initialization
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> cachedList = json.decode(cachedJson);
        _trends =
            cachedList.map((item) => Map<String, dynamic>.from(item)).toList();
        _isUsingFallbackData = false;
        debugPrint('Loaded ${_trends.length} trends from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached trends: $e');
    }
  }

  Future<void> _saveToCache(List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data));
      await prefs.setString(
          _cacheTimestampKey, DateTime.now().toIso8601String());
      debugPrint('Saved trends to cache');
    } catch (e) {
      debugPrint('Error saving trends to cache: $e');
    }
  }

  Future<void> loadLatestTrends({bool forceRefresh = false}) async {
    // If we already have data in memory and not forcing refresh, don't reload
    if (!forceRefresh && _trends.isNotEmpty && !_isLoading) {
      return;
    }

    // If not forcing refresh, try to load from cache first
    if (!forceRefresh && _trends.isEmpty) {
      await _loadCachedData();
      // If we have cached data, use it and don't call AI
      if (_trends.isNotEmpty) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    _isUsingFallbackData = false;
    notifyListeners();

    try {
      debugPrint('Loading latest trends from Gemini AI...');
      final trends =
          await AIService.generateLatestTrends(forceRefresh: forceRefresh);

      if (trends.isNotEmpty) {
        _trends = trends;
        _isUsingFallbackData = false;
        // Mark AI feature as used
        _aiUsageProvider?.markAIFeatureUsed();
        await _saveToCache(trends);
        debugPrint(
            'Successfully loaded ${trends.length} trends from AI and saved to cache');
      } else {
        // If AI returned empty, use fallback
        _trends = AIService.getDefaultTrends();
        _isUsingFallbackData = true;
        debugPrint('AI returned empty, using fallback data');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading latest trends: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      // Use fallback data on error
      _trends = AIService.getDefaultTrends();
      _isUsingFallbackData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
