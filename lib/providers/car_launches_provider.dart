import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';

class CarLaunchesProvider with ChangeNotifier {
  List<Map<String, dynamic>> _indiaCars = [];
  List<Map<String, dynamic>> _globalCars = [];
  bool _isLoading = false;
  String? _error;
  bool _isUsingFallbackData = false;
  static const String _cacheKey = 'car_launches_cache';
  static const String _cacheTimestampKey = 'car_launches_cache_timestamp';

  List<Map<String, dynamic>> get indiaCars => _indiaCars;
  List<Map<String, dynamic>> get globalCars => _globalCars;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsingFallbackData => _isUsingFallbackData;

  CarLaunchesProvider() {
    // Load cached data on initialization
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> cachedData = json.decode(cachedJson);
        _indiaCars = (cachedData['india'] as List?)
                ?.map((item) => Map<String, dynamic>.from(item))
                .toList() ??
            [];
        _globalCars = (cachedData['global'] as List?)
                ?.map((item) => Map<String, dynamic>.from(item))
                .toList() ??
            [];
        _isUsingFallbackData = false;
        debugPrint('Loaded ${_indiaCars.length} India cars and ${_globalCars.length} global cars from cache');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cached car launches: $e');
    }
  }

  Future<void> _saveToCache(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data));
      await prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
      debugPrint('Saved car launches to cache');
    } catch (e) {
      debugPrint('Error saving car launches to cache: $e');
    }
  }

  Future<void> loadLatestCarLaunches({bool forceRefresh = false}) async {
    // If we already have data in memory and not forcing refresh, don't reload
    if (!forceRefresh && _indiaCars.isNotEmpty && _globalCars.isNotEmpty && !_isLoading) {
      return;
    }

    // If not forcing refresh, try to load from cache first
    if (!forceRefresh && _indiaCars.isEmpty && _globalCars.isEmpty) {
      await _loadCachedData();
      // If we have cached data, use it and don't call AI
      if (_indiaCars.isNotEmpty || _globalCars.isNotEmpty) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    _isUsingFallbackData = false;
    notifyListeners();

    try {
      debugPrint('Loading latest car launches from Gemini AI...');
      final launches = await AIService.generateLatestCarLaunches(forceRefresh: forceRefresh);
      
      if (launches['india'] != null && launches['global'] != null) {
        _indiaCars = launches['india'] ?? [];
        _globalCars = launches['global'] ?? [];
        _isUsingFallbackData = false;
        await _saveToCache(launches);
        debugPrint('Successfully loaded ${_indiaCars.length} India cars and ${_globalCars.length} global cars from Gemini AI and saved to cache');
      } else {
        // If AI returned empty, use fallback
        final fallbackData = AIService.getDefaultCarLaunches();
        _indiaCars = fallbackData['india'] ?? [];
        _globalCars = fallbackData['global'] ?? [];
        _isUsingFallbackData = true;
        debugPrint('AI returned empty, using fallback data');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading latest car launches: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      // Use fallback data on error
      final fallbackData = AIService.getDefaultCarLaunches();
      _indiaCars = fallbackData['india'] ?? [];
      _globalCars = fallbackData['global'] ?? [];
      _isUsingFallbackData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

