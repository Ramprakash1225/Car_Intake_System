import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIUsageProvider with ChangeNotifier {
  bool _hasUsedAIFeature = false;

  bool get hasUsedAIFeature => _hasUsedAIFeature;

  AIUsageProvider() {
    _loadAIUsageStatus();
  }

  Future<void> _loadAIUsageStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _hasUsedAIFeature = prefs.getBool('has_used_ai_feature') ?? false;
    notifyListeners();
  }

  Future<void> markAIFeatureUsed() async {
    if (_hasUsedAIFeature) return; // Already marked
    
    _hasUsedAIFeature = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_used_ai_feature', true);
    notifyListeners();
  }

  Future<void> resetAIUsageStatus() async {
    _hasUsedAIFeature = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_used_ai_feature');
    notifyListeners();
  }
}

