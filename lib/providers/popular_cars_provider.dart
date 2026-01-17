import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'ai_usage_provider.dart';

class PopularCarsProvider with ChangeNotifier {
  AIUsageProvider? _aiUsageProvider;

  void setAIUsageProvider(AIUsageProvider provider) {
    _aiUsageProvider = provider;
  }
  List<Map<String, dynamic>> _popularCars = [];
  bool _isLoading = false;
  String _selectedRegion = 'all'; // 'all', 'worldwide', 'india'
  String? _error;
  bool _isUsingFallbackData = false;

  List<Map<String, dynamic>> get popularCars => _popularCars;
  bool get isLoading => _isLoading;
  String get selectedRegion => _selectedRegion;
  String? get error => _error;
  bool get isUsingFallbackData => _isUsingFallbackData;

  PopularCarsProvider() {
    // Start with empty data, wait for AI response
  }

  Future<void> loadPopularCars({String? region, bool forceRefresh = false}) async {
    // If we already have data and not forcing refresh, don't show loading
    if (!forceRefresh && _popularCars.isNotEmpty && !_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    _isUsingFallbackData = false;
    notifyListeners();

    try {
      final regionToUse = region ?? _selectedRegion;
      _selectedRegion = regionToUse;
      
      debugPrint('Loading popular cars from Gemini AI for region: $regionToUse');
      final cars = await AIService.getPopularCars(region: regionToUse, forceRefresh: forceRefresh);
      
      if (cars.isNotEmpty) {
        _popularCars = cars;
        _isUsingFallbackData = false;
        // Mark AI feature as used
        _aiUsageProvider?.markAIFeatureUsed();
        debugPrint('Successfully loaded ${cars.length} cars from Gemini AI');
      } else {
        // If AI returned empty, use fallback
        _popularCars = AIService.getDefaultPopularCars(regionToUse);
        _isUsingFallbackData = true;
        debugPrint('AI returned empty, using fallback data');
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading popular cars: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      // Use fallback data on error
      _popularCars = AIService.getDefaultPopularCars(region ?? _selectedRegion);
      _isUsingFallbackData = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? getCarByIndex(int index) {
    if (index >= 0 && index < _popularCars.length) {
      return _popularCars[index];
    }
    return null;
  }
}

