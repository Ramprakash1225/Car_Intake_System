class ImageHelper {
  // Feature-specific fallback asset images
  static const String latestTrendFallback = 'assets/fallback/latest_trend_fallback.jpg';
  static const String carLaunchesFallback = 'assets/fallback/upcommingcars_fallback.webp';
  static const String profitableCarsFallback = 'assets/fallback/profitable_car_fallback.avif';
  static const String tnMarketKingsFallback = 'assets/fallback/tnmarketking_fallback.webp';
  static const String dailyStrategyFallback = 'assets/fallback/daily_satergy_fallback.webp';
  static const String todaysChoiceFallback = 'assets/fallback/todayschoice_fallback.webp';
  static const String top5PicksFallback = 'assets/fallback/top5_fallback.webp';

  // Valid Unsplash image URLs for general automotive content (backup)
  static const List<String> fallbackCarImages = [
    'https://images.unsplash.com/photo-1492144534655-ae79c475c77c?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1606664515524-ed2f786a0ad6?w=800&auto=format&fit=crop',
  ];

  // Get feature-specific fallback asset image
  static String getFeatureFallbackAsset(String featureType) {
    switch (featureType) {
      case 'trends':
        return latestTrendFallback;
      case 'car_launches':
        return carLaunchesFallback;
      case 'profitable_cars':
        return profitableCarsFallback;
      case 'tn_market_kings':
        return tnMarketKingsFallback;
      case 'daily_strategy':
        return dailyStrategyFallback;
      case 'todays_choice':
        return todaysChoiceFallback;
      case 'top5_picks':
        return top5PicksFallback;
      default:
        return latestTrendFallback; // Default fallback
    }
  }

  // Get a fallback image URL based on index (for variety) - legacy support
  static String getFallbackImage(int index) {
    return fallbackCarImages[index % fallbackCarImages.length];
  }

  // Get a random fallback image - legacy support
  static String getRandomFallbackImage() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return fallbackCarImages[random % fallbackCarImages.length];
  }

  // Validate URL format - check if it's a valid Unsplash URL pattern
  static bool isValidUnsplashUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    // Check if it's a valid Unsplash URL pattern
    // Valid pattern: https://images.unsplash.com/photo-XXXXXXXXXX?...
    final unsplashPattern = RegExp(r'^https://images\.unsplash\.com/photo-[a-zA-Z0-9-]+');
    return unsplashPattern.hasMatch(url);
  }

  // Validate and return a valid image URL, or null if invalid (to use asset instead)
  static String? getValidImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null; // Use asset instead
    }
    
    // Only accept valid Unsplash URLs
    if (isValidUnsplashUrl(imageUrl)) {
      return imageUrl;
    }
    
    // If invalid format, return null to use asset
    return null;
  }
}

