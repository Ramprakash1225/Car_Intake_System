import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class Top5PicksProvider with ChangeNotifier {
  List<Map<String, dynamic>> _picks = [];
  bool _isLoading = false;
  String? _error;
  bool _isUsingFallbackData = false;
  String? _favoriteModel = '';
  String? _auctionPlan = '';
  String _locationFeedback = '';
  static const String _cacheKey = 'top5_picks_cache';
  static const String _cacheTimestampKey = 'top5_picks_cache_timestamp';

  List<Map<String, dynamic>> get picks => _picks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsingFallbackData => _isUsingFallbackData;
  String? get favoriteModel => _favoriteModel;
  String? get auctionPlan => _auctionPlan;
  String get locationFeedback => _locationFeedback;

  Top5PicksProvider() {
    // Load cached data on initialization
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> cachedList = json.decode(cachedJson);
        _picks = cachedList.map((item) => Map<String, dynamic>.from(item)).toList();
        _isUsingFallbackData = false;
        debugPrint('Loaded ${_picks.length} top 5 picks from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached top 5 picks: $e');
    }
  }

  Future<void> _saveToCache(List<Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      debugPrint('Saved top 5 picks to cache');
    } catch (e) {
      debugPrint('Error saving top 5 picks to cache: $e');
    }
  }

  Future<void> loadTop5Picks({bool forceRefresh = false}) async {
    // If we already have data in memory and not forcing refresh, don't reload
    if (!forceRefresh && _picks.isNotEmpty && !_isLoading) {
      return;
    }

    // If not forcing refresh, try to load from cache first
    if (!forceRefresh && _picks.isEmpty) {
      await _loadCachedData();
      // If we have cached data, use it and don't call AI
      if (_picks.isNotEmpty) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    _isUsingFallbackData = false;
    notifyListeners();

    try {
      debugPrint('Loading top 5 business picks from Gemini AI...');
      final picks = await AIService.generateTop5BusinessPicks(forceRefresh: forceRefresh);
      
      if (picks.isNotEmpty) {
        _picks = picks;
        _isUsingFallbackData = false;
        await _saveToCache(picks);
        debugPrint('Successfully loaded ${picks.length} top 5 picks from Gemini AI and saved to cache');
      } else {
        // If AI returned empty, use fallback
        _picks = AIService.getDefaultTop5BusinessPicks();
        _isUsingFallbackData = true;
        debugPrint('AI returned empty, using fallback data');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading top 5 picks: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      // Use fallback data on error
      _picks = AIService.getDefaultTop5BusinessPicks();
      _isUsingFallbackData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFavoriteModel(String? model) {
    _favoriteModel = model;
    notifyListeners();
  }

  void setAuctionPlan(String? plan) {
    _auctionPlan = plan;
    notifyListeners();
  }

  void setLocationFeedback(String feedback) {
    _locationFeedback = feedback;
    notifyListeners();
  }
}

