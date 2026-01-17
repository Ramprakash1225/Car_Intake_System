import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class TodaysChoiceProvider with ChangeNotifier {
  Map<String, dynamic> _choice = {};
  bool _isLoading = false;
  String? _error;
  bool _isUsingFallbackData = false;
  String? _reaction; // '👍' or '👎'
  String? _usageTracker; // 'ஆம்' or 'இல்லை'
  String _feedback = '';
  static const String _cacheKey = 'todays_choice_cache';
  static const String _cacheTimestampKey = 'todays_choice_cache_timestamp';

  Map<String, dynamic> get choice => _choice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsingFallbackData => _isUsingFallbackData;
  String? get reaction => _reaction;
  String? get usageTracker => _usageTracker;
  String get feedback => _feedback;

  TodaysChoiceProvider() {
    // Load cached data on initialization
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        _choice = Map<String, dynamic>.from(json.decode(cachedJson));
        _isUsingFallbackData = false;
        debugPrint('Loaded today\'s choice from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached today\'s choice: $e');
    }
  }

  Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      debugPrint('Saved today\'s choice to cache');
    } catch (e) {
      debugPrint('Error saving today\'s choice to cache: $e');
    }
  }

  Future<void> loadTodaysChoice({bool forceRefresh = false}) async {
    // If we already have data in memory and not forcing refresh, don't reload
    if (!forceRefresh && _choice.isNotEmpty && !_isLoading) {
      return;
    }

    // If not forcing refresh, try to load from cache first
    if (!forceRefresh && _choice.isEmpty) {
      await _loadCachedData();
      // If we have cached data, use it and don't call AI
      if (_choice.isNotEmpty) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    _isUsingFallbackData = false;
    notifyListeners();

    try {
      debugPrint('Loading today\'s choice from Gemini AI...');
      final choice = await AIService.generateTodaysChoice(forceRefresh: forceRefresh);
      
      if (choice.isNotEmpty) {
        _choice = choice;
        _isUsingFallbackData = false;
        await _saveToCache(choice);
        debugPrint('Successfully loaded today\'s choice from Gemini AI and saved to cache');
      } else {
        // If AI returned empty, use fallback
        _choice = AIService.getDefaultTodaysChoice();
        _isUsingFallbackData = true;
        debugPrint('AI returned empty, using fallback data');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading today\'s choice: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      // Use fallback data on error
      _choice = AIService.getDefaultTodaysChoice();
      _isUsingFallbackData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setReaction(String? reaction) {
    _reaction = reaction;
    notifyListeners();
  }

  void setUsageTracker(String? usageTracker) {
    _usageTracker = usageTracker;
    notifyListeners();
  }

  void setFeedback(String feedback) {
    _feedback = feedback;
    notifyListeners();
  }
}

