import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class DailyStrategyProvider with ChangeNotifier {
  Map<String, dynamic> _strategy = {};
  bool _isLoading = false;
  String? _error;
  bool _isUsingFallbackData = false;
  static const String _cacheKey = 'daily_strategy_cache';
  static const String _cacheTimestampKey = 'daily_strategy_cache_timestamp';

  Map<String, dynamic> get strategy => _strategy;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsingFallbackData => _isUsingFallbackData;

  DailyStrategyProvider() {
    // Load cached data on initialization
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        _strategy = Map<String, dynamic>.from(json.decode(cachedJson));
        _isUsingFallbackData = false;
        debugPrint('Loaded daily strategy from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached daily strategy: $e');
    }
  }

  Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      debugPrint('Saved daily strategy to cache');
    } catch (e) {
      debugPrint('Error saving daily strategy to cache: $e');
    }
  }

  Future<void> loadDailyStrategy({bool forceRefresh = false}) async {
    // If we already have data in memory and not forcing refresh, don't reload
    if (!forceRefresh && _strategy.isNotEmpty && !_isLoading) {
      return;
    }

    // If not forcing refresh, try to load from cache first
    if (!forceRefresh && _strategy.isEmpty) {
      await _loadCachedData();
      // If we have cached data, use it and don't call AI
      if (_strategy.isNotEmpty) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    _isUsingFallbackData = false;
    notifyListeners();

    try {
      debugPrint('Loading daily strategy from Gemini AI...');
      final strategy = await AIService.generateDailyStrategy(forceRefresh: forceRefresh);
      
      if (strategy.isNotEmpty) {
        _strategy = strategy;
        _isUsingFallbackData = false;
        await _saveToCache(strategy);
        debugPrint('Successfully loaded daily strategy from Gemini AI and saved to cache');
      } else {
        // If AI returned empty, use fallback
        _strategy = AIService.getDefaultDailyStrategy();
        _isUsingFallbackData = true;
        debugPrint('AI returned empty, using fallback data');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading daily strategy: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      // Use fallback data on error
      _strategy = AIService.getDefaultDailyStrategy();
      _isUsingFallbackData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

