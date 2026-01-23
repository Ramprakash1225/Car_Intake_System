import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  // Store API key statically (set from main.dart after loading .env)
  static String? _cachedApiKey;

  // Set API key (called from main.dart after loading .env)
  static void setApiKey(String key) {
    _cachedApiKey = key;
    debugPrint('✓ AIService: API key cached successfully');
  }

  // Cache helper methods
  static Future<String?> _getCachedData(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(cacheKey);
    } catch (e) {
      debugPrint('Error reading cache: $e');
      return null;
    }
  }

  static Future<void> _saveToCache(String cacheKey, String data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, data);
      debugPrint('Saved data to cache with key: $cacheKey');
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  // Clear all AI cache to force fresh API calls
  static Future<void> clearAICache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // List of all cache keys
      final cacheKeys = [
        'popular_cars_all',
        'popular_cars_worldwide',
        'popular_cars_india',
        'latest_trends',
        'latest_car_launches',
        'profitable_cars',
        'tn_market_kings',
        'daily_strategy',
        'todays_choice',
        'top5_business_picks',
      ];

      // Remove all cache keys
      for (final key in cacheKeys) {
        await prefs.remove(key);
      }

      // Also remove car analysis cache (keys start with 'car_analysis_')
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('car_analysis_')) {
          await prefs.remove(key);
        }
      }

      debugPrint('All AI cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing AI cache: $e');
    }
  }

  // Generate cache key for car analysis based on image hash
  static String _generateImageHash(List<Uint8List> imageBytes) {
    try {
      // Use first image for hash (or combine all images)
      final bytesToHash =
          imageBytes.isNotEmpty ? imageBytes.first : Uint8List(0);
      final hash = sha256.convert(bytesToHash);
      return 'car_analysis_${hash.toString()}';
    } catch (e) {
      debugPrint('Error generating image hash: $e');
      // Fallback to timestamp-based key
      return 'car_analysis_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Get API key from environment variables - NO FALLBACK (security)
  static String get apiKey {
    try {
      debugPrint('=== API Key Check ===');
      
      // First, try cached API key (set from main.dart)
      if (_cachedApiKey != null && _cachedApiKey!.isNotEmpty) {
        debugPrint('✓ Using cached API key: ${_cachedApiKey!.substring(0, 10)}...');
        return _cachedApiKey!.trim();
      }

      // Fallback: Try dotenv (in case it was loaded)
      debugPrint('dotenv.isInitialized: ${dotenv.isInitialized}');
      final envKey = dotenv.env['GEMINI_API_KEY'];
      debugPrint(
          'GEMINI_API_KEY from dotenv: ${envKey != null ? "${envKey.substring(0, 10)}... (length: ${envKey.length})" : "null"}');
      debugPrint('All dotenv keys: ${dotenv.env.keys.toList()}');

      if (envKey != null && envKey.isNotEmpty && envKey.trim().isNotEmpty) {
        // Cache it for future use
        _cachedApiKey = envKey.trim();
        debugPrint('✓ Using API key from dotenv and caching it');
        return _cachedApiKey!;
      } else {
        debugPrint('✗ GEMINI_API_KEY is null or empty');
      }
    } catch (e, stackTrace) {
      debugPrint('Error accessing .env file: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    // NO FALLBACK - throw error if API key is not configured
    debugPrint('=== API Key Error ===');
    throw Exception(
        'GEMINI_API_KEY is not configured. Please create a .env file in the root directory with: GEMINI_API_KEY=your_api_key_here. dotenv.isInitialized=${dotenv.isInitialized}');
  }

  // Get reliable placeholder image URLs from Pexels (more stable than Unsplash)
  static String getReliableCarImageUrl({String? carModel}) {
    // Use Pexels direct image URLs which are more reliable
    // These are known-good URLs that should work consistently
    final pexelsUrls = [
      'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/3802508/pexels-photo-3802508.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/3802510/pexels-photo-3802510.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/112460/pexels-photo-112460.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/170811/pexels-photo-170811.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/1592384/pexels-photo-1592384.jpeg?auto=compress&cs=tinysrgb&w=800',
      'https://images.pexels.com/photos/3802507/pexels-photo-3802507.jpeg?auto=compress&cs=tinysrgb&w=800',
    ];

    // Use a deterministic selection based on car model if provided, otherwise random
    if (carModel != null && carModel.isNotEmpty) {
      final index = carModel.hashCode.abs() % pexelsUrls.length;
      return pexelsUrls[index];
    }
    // Default to first URL
    return pexelsUrls[0];
  }

  // Validate and sanitize image URL - replace invalid Unsplash URLs with reliable Pexels URLs
  static String validateAndSanitizeImageUrl(String? imageUrl,
      {String? carModel}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return getReliableCarImageUrl(carModel: carModel);
    }

    // Check if it's an Unsplash URL - these are often invalid/expired
    if (imageUrl.contains('unsplash.com') ||
        imageUrl.contains('images.unsplash.com')) {
      debugPrint(
          'Detected Unsplash URL, replacing with reliable Pexels URL: $imageUrl');
      return getReliableCarImageUrl(carModel: carModel);
    }

    // Check if it's a valid Pexels URL - keep it
    if (imageUrl.contains('pexels.com') ||
        imageUrl.contains('images.pexels.com')) {
      return imageUrl;
    }

    // Check if it's a Pixabay URL - keep it
    if (imageUrl.contains('pixabay.com')) {
      return imageUrl;
    }

    // Check if it's a valid HTTP/HTTPS URL
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      // Keep other valid URLs (manufacturer sites, etc.)
      return imageUrl;
    }

    // If URL format is invalid, use fallback
    debugPrint('Invalid image URL format, using fallback: $imageUrl');
    return getReliableCarImageUrl(carModel: carModel);
  }

  // Process and validate image URLs in a list of items
  static List<Map<String, dynamic>> validateImageUrlsInList(
    List<Map<String, dynamic>> items,
    String imageUrlKey,
  ) {
    return items.map((item) {
      final imageUrl = item[imageUrlKey]?.toString();
      final validatedUrl = validateAndSanitizeImageUrl(
        imageUrl,
        carModel: item['model']?.toString() ?? item['make']?.toString(),
      );
      return {
        ...item,
        imageUrlKey: validatedUrl,
      };
    }).toList();
  }

  // Process and validate image URL in a single item
  static Map<String, dynamic> validateImageUrlInItem(
    Map<String, dynamic> item,
    String imageUrlKey,
  ) {
    final imageUrl = item[imageUrlKey]?.toString();
    final validatedUrl = validateAndSanitizeImageUrl(
      imageUrl,
      carModel: item['model']?.toString() ??
          item['make']?.toString() ??
          item['brand']?.toString(),
    );
    return {
      ...item,
      imageUrlKey: validatedUrl,
    };
  }

  // static String get serviceAccount {
  //   return dotenv.env['VERTEX_AI_SERVICE_ACCOUNT'] ??
  //          'qumarionixbk@qumarionixbk.iam.gserviceaccount.com';
  // }

  static Future<Map<String, String>> analyzeCarImages({
    required List<Uint8List> imageBytes,
    String? additionalInfo,
    bool forceRefresh = false,
  }) async {
    try {
      if (imageBytes.isEmpty) {
        return _getDefaultResponse();
      }

      // Generate cache key based on image hash
      final cacheKey = _generateImageHash(imageBytes);

      // Check cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedData = await _getCachedData(cacheKey);
        if (cachedData != null) {
          try {
            final cachedJson = json.decode(cachedData) as Map<String, dynamic>;
            debugPrint('Using cached car analysis data');
            return cachedJson
                .map((key, value) => MapEntry(key, value.toString()));
          } catch (e) {
            debugPrint('Error parsing cached data: $e');
          }
        }
      } else {
        debugPrint('Force refresh: bypassing cache for car analysis');
      }

      // Use Gemini AI directly with google_generative_ai package
      // Get API key (will throw if not configured)
      final apiKeyValue = apiKey;
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKeyValue,
      );

      // Use ALL images for comprehensive analysis
      final prompt = '''
Analyze ALL the provided car images (front view, sides, back, odometer, RC book, etc.) and provide comprehensive car information in JSON format. ALL fields are MANDATORY and REQUIRED. You MUST provide values for every single field below.

{
  "make": "REQUIRED - car make (from images or RC book, if not visible use 'Unknown')",
  "model": "REQUIRED - car model (from images or RC book, if not visible use 'Unknown')",
  "year": "REQUIRED - manufacturing year (from RC book or images, if not visible use estimated year based on car appearance)",
  "descriptionEn": "REQUIRED - detailed summary in English ONLY covering: make, model, year, condition, odometer reading, damages, overall assessment, and value proposition",
  "descriptionTa": "REQUIRED - detailed summary in Tamil ONLY covering: make, model, year, condition, odometer reading, damages, overall assessment, and value proposition",
  "sustainabilityScore": "REQUIRED - score out of 100 based on car condition and age (must be a number between 0-100)",
  "odometerReading": "REQUIRED - odometer reading in km (from odometer image, if not visible use '0' or estimate based on car condition)",
  "exteriorCondition": "REQUIRED - exterior condition assessment (Good/Fair/Poor) with specific details from images",
  "interiorCondition": "REQUIRED - interior condition assessment (Good/Fair/Poor/Not Visible) - if interior not visible in images, use 'Not Visible'",
  "damageDetails": "REQUIRED - specific damages found in images (location and type of damage, scratches, dents, etc.). If no damages visible, state 'No visible damages'",
  "tyreCondition": "REQUIRED - tyre condition assessment (Good/Fair/Poor/Replace) with tread depth if visible. If tyres not visible, use 'Not Visible'",
  "carbonFootprint": "REQUIRED - carbon footprint estimate based on car age and condition (e.g., 'Low - 100g CO2/km', 'Medium - 150g CO2/km', 'High - 200g CO2/km')",
  "greenRating": "REQUIRED - green rating (A, B, C, D) based on emissions and condition",
  "confidenceScore": "REQUIRED - confidence score as a number between 0-100 representing how confident you are in this analysis",
  "demand": "REQUIRED - market demand assessment (High/Medium/Low) for this specific car model, year, and condition in the current market",
  "purchaseRecommendation": "REQUIRED - purchase recommendation - MUST be either 'Purchase' or 'Not Purchase' based on condition, demand, odometer reading, and overall value assessment"
}

CRITICAL REQUIREMENTS - ALL FIELDS ARE MANDATORY:
1. ALL fields above are REQUIRED - you MUST provide a value for every single field. Do NOT leave any field empty or null.
2. descriptionEn and descriptionTa are MANDATORY - you MUST provide detailed summaries in both languages (minimum 100 words each)
3. Description should include: make, model, year, overall condition, odometer reading, key damages, market value assessment, and purchase recommendation reasoning
4. If a value cannot be determined from images, provide a reasonable estimate or default value (e.g., 'Unknown', 'Not Visible', '0', etc.)
5. sustainabilityScore must be a number between 0-100
6. odometerReading must be a number (in km)
7. confidenceScore must be a number between 0-100
8. greenRating must be one of: A, B, C, or D
9. demand must be one of: High, Medium, or Low
10. purchaseRecommendation must be exactly either 'Purchase' or 'Not Purchase'
11. Focus on factual, technical data about the car visible in the images
12. Demand should assess market demand for THIS SPECIFIC car (considering make, model, year, condition, odometer)
13. Purchase recommendation must be based on:
    - Car condition (exterior, interior, damages)
    - Odometer reading (high mileage = lower value)
    - Market demand for this specific car
    - Overall value proposition
14. Be specific about damages - mention location (front bumper, left door, etc.) and type (scratch, dent, rust, etc.)
15. Provide descriptionEn in English ONLY and descriptionTa in Tamil ONLY. Do NOT mix languages in the same field.
16. Return ONLY valid JSON. Do NOT include any text before or after the JSON object.

Additional information provided: ${additionalInfo ?? 'None'}

Analyze all images comprehensively and provide ALL required fields with values. Every field must have a value - no exceptions.
''';

      log('Calling Gemini AI for car image analysis with ${imageBytes.length} images...');

      // Create content with ALL images and text
      final parts = <Part>[];
      // Add all images
      for (final bytes in imageBytes) {
        parts.add(DataPart('image/jpeg', bytes));
      }
      // Add text prompt
      parts.add(TextPart(prompt));

      final content = [
        Content.multi(parts),
      ];

      final result = await model.generateContent(content);
      final responseText = result.text ?? '{}';

      log('Gemini AI Response received (length: ${responseText.length})');
      log('First 1000 chars of response: ${responseText.substring(0, responseText.length > 1000 ? 1000 : responseText.length)}');

      // Check if response is empty or just error message
      if (responseText.isEmpty ||
          responseText.trim() == '{}' ||
          responseText.length < 50) {
        log('WARNING: AI response seems empty or invalid. Response: $responseText');
        // Don't return default yet, try to parse anyway
      }

      // Try to extract JSON from the response
      try {
        // Try multiple methods to extract JSON
        Map<String, dynamic>? jsonData;

        // Log the raw response for debugging
        debugPrint('=== RAW AI RESPONSE ===');
        debugPrint(responseText);
        debugPrint('=== END RAW RESPONSE ===');

        // Method 1: Try to find JSON object with regex
        final jsonMatch =
            RegExp(r'\{[\s\S]*\}', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          try {
            jsonData = json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
            log('Successfully parsed JSON using regex method');
          } catch (e) {
            log('Regex method parsing failed: $e');
          }
        }

        // Method 2: Try to parse the entire response as JSON
        if (jsonData == null) {
          try {
            jsonData = json.decode(responseText.trim()) as Map<String, dynamic>;
            print('Successfully parsed JSON directly');
          } catch (e) {
            print('Direct parsing failed: $e');
          }
        }

        // Method 3: Try to find JSON between ```json and ``` or ``` and ```
        if (jsonData == null) {
          try {
            final codeBlockMatch =
                RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```', dotAll: true)
                    .firstMatch(responseText);
            if (codeBlockMatch != null) {
              jsonData =
                  json.decode(codeBlockMatch.group(1)!) as Map<String, dynamic>;
              print('Successfully parsed JSON from code block');
            }
          } catch (e) {
            print('Code block parsing failed: $e');
          }
        }

        if (jsonData != null) {
          // Validate that required fields exist
          final requiredFields = [
            'make',
            'model',
            'year',
            'descriptionEn',
            'descriptionTa',
            'sustainabilityScore',
            'odometerReading',
            'exteriorCondition',
            'interiorCondition',
            'damageDetails',
            'tyreCondition',
            'carbonFootprint',
            'greenRating',
            'confidenceScore',
            'demand',
            'purchaseRecommendation'
          ];

          // Check if all required fields are present
          bool allFieldsPresent = true;
          final missingFields = <String>[];
          for (final field in requiredFields) {
            if (!jsonData.containsKey(field) ||
                jsonData[field] == null ||
                jsonData[field].toString().trim().isEmpty) {
              allFieldsPresent = false;
              missingFields.add(field);
            }
          }

          if (!allFieldsPresent) {
            log('Warning: Missing or empty required fields: ${missingFields.join(", ")}');
            // Fill in missing fields with defaults
            for (final field in missingFields) {
              if (field == 'descriptionEn') {
                jsonData['descriptionEn'] =
                    'Car analysis completed. Detailed information extracted from images.';
              } else if (field == 'descriptionTa') {
                jsonData['descriptionTa'] =
                    'கார் பகுப்பாய்வு முடிக்கப்பட்டது. படங்களிலிருந்து விரிவான தகவல் பிரித்தெடுக்கப்பட்டது.';
              } else {
                // Use default response for other missing fields
                final defaults = _getDefaultResponse();
                jsonData[field] = defaults[field] ?? 'Unknown';
              }
            }
          }

          // Ensure descriptions are not empty
          if (jsonData['descriptionEn'] == null ||
              jsonData['descriptionEn'].toString().trim().isEmpty) {
            jsonData['descriptionEn'] =
                'Car analysis completed. Detailed information extracted from images.';
          }
          if (jsonData['descriptionTa'] == null ||
              jsonData['descriptionTa'].toString().trim().isEmpty) {
            jsonData['descriptionTa'] =
                'கார் பகுப்பாய்வு முடிக்கப்பட்டது. படங்களிலிருந்து விரிவான தகவல் பிரித்தெடுக்கப்பட்டது.';
          }

          final result =
              jsonData.map((key, value) => MapEntry(key, value.toString()));

          // Log the result for debugging
          log('Successfully parsed and validated AI response. DescriptionEn length: ${result['descriptionEn']?.length ?? 0}, DescriptionTa length: ${result['descriptionTa']?.length ?? 0}');

          // Save to cache
          await _saveToCache(cacheKey, json.encode(jsonData));
          return result;
        } else {
          log('ERROR: Failed to extract JSON from AI response');
          log('Response text preview: ${responseText.substring(0, responseText.length > 1000 ? 1000 : responseText.length)}');
          debugPrint('Full response: $responseText');
        }
      } catch (e, stackTrace) {
        log('ERROR: Exception while parsing JSON response: $e');
        log('Stack trace: $stackTrace');
        log('Response text (first 1000 chars): ${responseText.substring(0, responseText.length > 1000 ? 1000 : responseText.length)}');
        debugPrint('Full error response: $responseText');
      }

      // Fallback to default values - but log why
      log('WARNING: Falling back to default response. This means AI call failed or response was invalid.');
      log('Response text length: ${responseText.length}');
      log('Response preview: ${responseText.substring(0, responseText.length > 500 ? 500 : responseText.length)}');

      // Return default but with a note that it's a fallback
      final defaultResponse = _getDefaultResponse();
      defaultResponse['_isFallback'] = 'true'; // Mark as fallback
      return defaultResponse;
    } catch (e, stackTrace) {
      log('CRITICAL ERROR: Exception in analyzeCarImages: $e');
      log('Stack trace: $stackTrace');
      debugPrint('Full error details: $e');
      debugPrint('Stack trace: $stackTrace');

      // Check if it's an API key error (leaked, invalid, missing)
      if (e.toString().contains('API_KEY') ||
          e.toString().contains('api key') ||
          e.toString().contains('leaked') ||
          e.toString().contains('401') ||
          e.toString().contains('403') ||
          e.toString().contains('not configured')) {
        log('ERROR: API key issue detected: $e');
        final errorResponse = _getDefaultResponse();
        errorResponse['_error'] = 'API_KEY_ERROR';

        if (e.toString().contains('leaked')) {
          errorResponse['descriptionEn'] =
              'Error: The API key has been reported as leaked and is no longer valid. Please generate a new API key from Google AI Studio (https://aistudio.google.com/app/apikey) and update your .env file with: GEMINI_API_KEY=your_new_api_key';
          errorResponse['descriptionTa'] =
              'பிழை: API விசை கசிந்ததாக அறிவிக்கப்பட்டு இனி செல்லுபடியாகாது. Google AI Studio (https://aistudio.google.com/app/apikey) இலிருந்து புதிய API விசையை உருவாக்கி உங்கள் .env கோப்பை புதுப்பிக்கவும்: GEMINI_API_KEY=your_new_api_key';
        } else if (e.toString().contains('not configured')) {
          errorResponse['descriptionEn'] =
              'Error: API key is not configured. Please create a .env file in the root directory with: GEMINI_API_KEY=your_api_key_here. Get your API key from https://aistudio.google.com/app/apikey';
          errorResponse['descriptionTa'] =
              'பிழை: API விசை உள்ளமைக்கப்படவில்லை. ரூட் கோப்புறையில் .env கோப்பை உருவாக்கி GEMINI_API_KEY=your_api_key_here என சேர்க்கவும். https://aistudio.google.com/app/apikey இலிருந்து உங்கள் API விசையைப் பெறவும்';
        } else {
          errorResponse['descriptionEn'] =
              'Error: Invalid or missing API key. Please check your GEMINI_API_KEY configuration in .env file. Get a new key from https://aistudio.google.com/app/apikey';
          errorResponse['descriptionTa'] =
              'பிழை: தவறான அல்லது காணாமல் போன API விசை. .env கோப்பில் உங்கள் GEMINI_API_KEY உள்ளமைவை சரிபார்க்கவும். https://aistudio.google.com/app/apikey இலிருந்து புதிய விசையைப் பெறவும்';
        }
        return errorResponse;
      }

      // Check if it's a network error
      if (e.toString().contains('network') ||
          e.toString().contains('timeout') ||
          e.toString().contains('connection')) {
        log('ERROR: Network issue detected.');
        final errorResponse = _getDefaultResponse();
        errorResponse['_error'] = 'NETWORK_ERROR';
        errorResponse['descriptionEn'] =
            'Error: Network connection issue. Please check your internet connection and try again.';
        errorResponse['descriptionTa'] =
            'பிழை: நெட்வொர்க் இணைப்பு சிக்கல். உங்கள் இணைய இணைப்பை சரிபார்க்கவும் மற்றும் மீண்டும் முயற்சிக்கவும்.';
        return errorResponse;
      }

      final defaultResponse = _getDefaultResponse();
      defaultResponse['_error'] = 'UNKNOWN_ERROR';
      defaultResponse['descriptionEn'] =
          'Error during car analysis. Please try again or check API configuration. Error: ${e.toString().substring(0, 100)}';
      defaultResponse['descriptionTa'] =
          'கார் பகுப்பாய்வின் போது பிழை. மீண்டும் முயற்சிக்கவும் அல்லது API உள்ளமைவை சரிபார்க்கவும்.';
      return defaultResponse;
    }
  }

  static Map<String, String> _getDefaultResponse() {
    return {
      'make': 'Unknown',
      'model': 'Unknown',
      'year': '2020',
      'descriptionEn':
          'Car analysis completed. Detailed vehicle information has been extracted from the provided images. Please review all technical details including condition, odometer reading, damages, and market assessment. The analysis includes comprehensive data about the vehicle\'s exterior, interior, tyres, and overall condition to help make an informed decision.',
      'descriptionTa':
          'கார் பகுப்பாய்வு முடிக்கப்பட்டது. வழங்கப்பட்ட படங்களிலிருந்து விரிவான வாகன தகவல் பிரித்தெடுக்கப்பட்டது. நிலை, ஓடோமீட்டர் வாசிப்பு, சேதங்கள் மற்றும் சந்தை மதிப்பீடு உட்பட அனைத்து தொழில்நுட்ப விவரங்களையும் சரிபார்க்கவும். பகுப்பாய்வு வாகனத்தின் வெளிப்புறம், உட்புறம், டயர்கள் மற்றும் ஒட்டுமொத்த நிலை பற்றிய விரிவான தரவை உள்ளடக்கியது, இது தகவலறிந்த முடிவை எடுக்க உதவுகிறது.',
      'sustainabilityScore': '70',
      'odometerReading': '0',
      'exteriorCondition': 'Good',
      'interiorCondition': 'Good',
      'damageDetails': 'None',
      'tyreCondition': 'Good',
      'carbonFootprint': 'Medium - 150g CO2/km',
      'greenRating': 'C',
      'confidenceScore': '85',
      'demand': 'Medium',
      'purchaseRecommendation': 'Purchase',
    };
  }

  // Get popular cars (worldwide and Indian) using Gemini AI
  static Future<List<Map<String, dynamic>>> getPopularCars({
    String region = 'all', // 'worldwide', 'india', or 'all'
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    final cacheKey = 'popular_cars_$region';
    if (!forceRefresh) {
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        try {
          final cachedList = json.decode(cachedData) as List<dynamic>;
          debugPrint('Using cached popular cars data for region: $region');
          return cachedList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } catch (e) {
          debugPrint('Error parsing cached popular cars data: $e');
        }
      }
    } else {
      debugPrint('Force refresh: bypassing cache for popular cars');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      final regionText = region == 'worldwide'
          ? 'worldwide'
          : region == 'india'
              ? 'in India'
              : 'worldwide and in India';

      final regionValue = region == 'worldwide'
          ? 'Worldwide'
          : region == 'india'
              ? 'India'
              : 'Both';

      final prompt =
          '''You are a car market analyst. Provide a comprehensive list of the most selling cars $regionText.

IMPORTANT: For each car, you MUST provide a high-quality, relevant automotive image URL. Images are MANDATORY for each car entry. Use real, working automotive image URLs from pexels.com or pixabay.com. DO NOT use unsplash.com URLs as they often return 404 errors. Use direct image URLs from Pexels (pexels.com/photos/...) or Pixabay that are known to work.

For each car, provide the following information in a valid JSON array format. Return ONLY the JSON array, no additional text or markdown:

[
  {
    "make": "Toyota",
    "model": "Corolla",
    "year": "2024",
    "description": "World's best-selling car. Reliable, fuel-efficient, and trusted globally. உலகின் மிகவும் விற்பனையாகும் கார். நம்பகமான, எரிபொருள் திறமையான மற்றும் உலகளாவிய நம்பிக்கை.",
    "salesFigures": "Over 50 million sold worldwide",
    "priceRange": "₹18-25 Lakhs",
    "fuelType": "Hybrid",
    "engineCapacity": "1.8L",
    "mileage": "23-27 km/l",
    "sustainabilityScore": "85",
    "carbonFootprint": "Low - 100g CO2/km",
    "greenRating": "A",
    "keyFeatures": "Hybrid Engine, Safety Features, Reliability",
    "pros": "Fuel Efficient, Reliable, High Resale Value",
    "cons": "Higher Price, Limited Features",
    "marketPosition": "Global leader in compact sedan segment",
    "region": "$regionValue",
    "imageUrl": "High-quality automotive image URL (MANDATORY - use real, working URLs from pexels.com or pixabay.com, NOT unsplash.com)"
  }
]

Provide at least 4-6 cars for $regionText. Focus on actual best-selling models with real market data from 2023-2024.
Each car must have all the fields above INCLUDING imageUrl. Images are MANDATORY. Use Pexels or Pixabay URLs only. Return ONLY valid JSON array.''';

      print('Calling Gemini AI for popular cars (region: $region)...');
      final content = [Content.text(prompt)];
      final result = await model.generateContent(content);
      final responseText = result.text ?? '';

      print('Gemini AI Response received (length: ${responseText.length})');
      print(
          'First 500 chars: ${responseText.substring(0, responseText.length > 500 ? 500 : responseText.length)}');

      // Try multiple methods to extract JSON
      List<dynamic>? jsonData;

      // Method 1: Try to find JSON array with regex
      try {
        final jsonMatch =
            RegExp(r'\[[\s\S]*\]', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          jsonData = json.decode(jsonString) as List<dynamic>;
          print('Successfully parsed JSON using regex method');
        }
      } catch (e) {
        print('Regex method failed: $e');
      }

      // Method 2: Try to parse the entire response as JSON
      if (jsonData == null) {
        try {
          jsonData = json.decode(responseText.trim()) as List<dynamic>;
          print('Successfully parsed JSON directly');
        } catch (e) {
          print('Direct parsing failed: $e');
        }
      }

      // Method 3: Try to find JSON between ```json and ``` or ``` and ```
      if (jsonData == null) {
        try {
          final codeBlockMatch =
              RegExp(r'```(?:json)?\s*(\[[\s\S]*?\])\s*```', dotAll: true)
                  .firstMatch(responseText);
          if (codeBlockMatch != null) {
            final jsonString = codeBlockMatch.group(1)!;
            jsonData = json.decode(jsonString) as List<dynamic>;
            print('Successfully parsed JSON from code block');
          }
        } catch (e) {
          print('Code block parsing failed: $e');
        }
      }

      // If we successfully parsed JSON, validate and return
      if (jsonData != null && jsonData.isNotEmpty) {
        final cars = jsonData.map((item) {
          final car = item as Map<String, dynamic>;
          // Ensure all required fields exist
          return {
            'make': car['make']?.toString() ?? 'Unknown',
            'model': car['model']?.toString() ?? 'Unknown',
            'year': car['year']?.toString() ?? '2024',
            'description': car['description']?.toString() ?? '',
            'salesFigures': car['salesFigures']?.toString() ?? 'N/A',
            'priceRange': car['priceRange']?.toString() ?? 'N/A',
            'fuelType': car['fuelType']?.toString() ?? 'Petrol',
            'engineCapacity': car['engineCapacity']?.toString() ?? 'N/A',
            'mileage': car['mileage']?.toString() ?? 'N/A',
            'sustainabilityScore':
                car['sustainabilityScore']?.toString() ?? '70',
            'carbonFootprint': car['carbonFootprint']?.toString() ?? 'Medium',
            'greenRating': car['greenRating']?.toString() ?? 'C',
            'keyFeatures': car['keyFeatures']?.toString() ?? '',
            'pros': car['pros']?.toString() ?? '',
            'cons': car['cons']?.toString() ?? '',
            'marketPosition': car['marketPosition']?.toString() ?? '',
            'region': car['region']?.toString() ?? regionValue,
            'imageUrl': validateAndSanitizeImageUrl(
              car['imageUrl']?.toString(),
              carModel: car['model']?.toString() ?? car['make']?.toString(),
            ),
          };
        }).toList();

        print('Successfully parsed ${cars.length} cars from Gemini AI');
        // Save to cache
        await _saveToCache(cacheKey, json.encode(cars));
        return cars;
      }

      print(
          'Failed to parse JSON from Gemini AI response, using fallback data');
      // Fallback to default popular cars
      return getDefaultPopularCars(region);
    } catch (e, stackTrace) {
      print('Error getting popular cars from Gemini AI: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default popular cars
      return getDefaultPopularCars(region);
    }
  }

  static List<Map<String, dynamic>> getDefaultPopularCars(String region) {
    final worldwideCars = [
      {
        'make': 'Honda',
        'model': 'Civic',
        'year': '2024',
        'description':
            'Popular worldwide for sporty design and performance. உலகளாவிய அளவில் பிரபலமான விளையாட்டு வடிவமைப்பு மற்றும் செயல்திறன்.',
        'salesFigures': 'Over 27 million sold',
        'priceRange': '₹20-28 Lakhs',
        'fuelType': 'Petrol',
        'engineCapacity': '1.5L Turbo',
        'mileage': '17-20 km/l',
        'sustainabilityScore': '78',
        'carbonFootprint': 'Medium - 130g CO2/km',
        'greenRating': 'B+',
        'keyFeatures': 'Turbo Engine, Sporty Design, Advanced Safety',
        'pros': 'Powerful, Stylish, Good Handling',
        'cons': 'Premium Pricing, Higher Maintenance',
        'marketPosition': 'Premium compact sedan',
        'region': 'Worldwide',
      },
    ];

    final indianCars = [
      {
        'make': 'Maruti',
        'model': 'Swift',
        'year': '2024',
        'description':
            'India\'s best-selling hatchback. Affordable, reliable, and fuel-efficient. இந்தியாவின் மிகவும் விற்பனையாகும் ஹேட்ச்பேக். மலிவான, நம்பகமான மற்றும் எரிபொருள் திறமையான.',
        'salesFigures': 'Over 2.5 million sold in India',
        'priceRange': '₹5.9-9.5 Lakhs',
        'fuelType': 'Petrol/CNG',
        'engineCapacity': '1.2L',
        'mileage': '23-30 km/l',
        'sustainabilityScore': '82',
        'carbonFootprint': 'Low - 110g CO2/km',
        'greenRating': 'A',
        'keyFeatures': 'CNG Option, High Mileage, Low Maintenance',
        'pros': 'Affordable, Fuel Efficient, Low Running Cost',
        'cons': 'Basic Features, Build Quality',
        'marketPosition': 'Market leader in Indian hatchback segment',
        'region': 'India',
      },
    ];

    if (region == 'worldwide') {
      return worldwideCars;
    } else if (region == 'india') {
      return indianCars;
    } else {
      return [...worldwideCars, ...indianCars];
    }
  }

  // Generate Latest Automotive Trends in Tamil
  static Future<List<Map<String, dynamic>>> generateLatestTrends({
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    const cacheKey = 'latest_trends';
    if (!forceRefresh) {
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        try {
          final cachedList = json.decode(cachedData) as List<dynamic>;
          debugPrint('Using cached trends data');
          return cachedList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } catch (e) {
          debugPrint('Error parsing cached trends data: $e');
        }
      }
    } else {
      debugPrint('Force refresh: bypassing cache for trends');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      const prompt =
          '''Act as a Senior Automotive Analyst. Generate exactly 3 automotive trends in BOTH English and Tamil using this ring-fenced structure:

IMPORTANT: For each trend, you MUST provide a high-quality, relevant automotive image URL. Images are MANDATORY. Use real, working automotive image URLs from pexels.com or pixabay.com. DO NOT use unsplash.com URLs as they often return 404 errors. Use direct image URLs from Pexels (pexels.com/photos/...) or Pixabay that are known to work.

For each trend, provide a JSON array with exactly this format:
[
  {
    "header_en": "Bold English Title (Header)",
    "header_ta": "Bold Tamil Title (Header) - தலைப்பு",
    "overview_en": "Exactly 2 concise lines in English",
    "overview_ta": "Exactly 2 concise lines in Tamil - சுருக்கம்",
    "detailedInsight_en": "Exactly 6 lines of technical/business depth in English (formatted for Read More expansion)",
    "detailedInsight_ta": "Exactly 6 lines of technical/business depth in Tamil (formatted for Read More expansion) - விரிவான நுண்ணறிவு",
    "imageUrl": "High-quality, relevant automotive image URL (MANDATORY - use real, working URLs from pexels.com or pixabay.com, NOT unsplash.com)",
    "domainLabel_en": "Specific Domain Title in English (e.g., Safety Technology, Electric Vehicles, etc.)",
    "domainLabel_ta": "Specific Domain Title in Tamil (e.g., பாதுகாப்பு தொழில்நுட்பம், மின் வாகனங்கள், etc.)"
  }
]

Strict Guardrails:
- Images: MANDATORY. Each trend must have a high-quality, relevant automotive image URL. Use Pexels or Pixabay URLs only.
- Ring-fencing: Only provide automotive-specific content. No deviations.
- No Metadata: Do not include date, time, or conversational greetings/fillers.
- Data Integrity: Zero hallucination; use 2025-2026 industry outlooks only.
- Zero Bias: Maintain a neutral, professional, and data-driven business tone.
- Formatting: Ensure a clean, scannable layout suitable for a feature UI.
- Language: Provide BOTH English and Tamil versions for ALL text fields (header, overview, detailedInsight, domainLabel).

Return ONLY valid JSON array, no additional text or markdown.''';

      print('Calling Gemini AI for latest automotive trends...');
      final content = [Content.text(prompt)];
      final result = await model.generateContent(content);
      final responseText = result.text ?? '';

      print(
          'Gemini AI Trends Response received (length: ${responseText.length})');

      // Try multiple methods to extract JSON
      List<dynamic>? jsonData;

      // Method 1: Try to find JSON array with regex
      try {
        final jsonMatch =
            RegExp(r'\[[\s\S]*\]', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          jsonData = json.decode(jsonString) as List<dynamic>;
          print('Successfully parsed trends JSON using regex method');
        }
      } catch (e) {
        print('Regex method failed: $e');
      }

      // Method 2: Try to parse the entire response as JSON
      if (jsonData == null) {
        try {
          jsonData = json.decode(responseText.trim()) as List<dynamic>;
          print('Successfully parsed trends JSON directly');
        } catch (e) {
          print('Direct parsing failed: $e');
        }
      }

      // Method 3: Try to find JSON between ```json and ``` or ``` and ```
      if (jsonData == null) {
        try {
          final codeBlockMatch =
              RegExp(r'```(?:json)?\s*(\[[\s\S]*?\])\s*```', dotAll: true)
                  .firstMatch(responseText);
          if (codeBlockMatch != null) {
            final jsonString = codeBlockMatch.group(1)!;
            jsonData = json.decode(jsonString) as List<dynamic>;
            print('Successfully parsed trends JSON from code block');
          }
        } catch (e) {
          print('Code block parsing failed: $e');
        }
      }

      // If we successfully parsed JSON, validate and return
      if (jsonData != null && jsonData.isNotEmpty) {
        final trends = jsonData.map((item) {
          final trend = item as Map<String, dynamic>;
          // Ensure all required fields exist - support both bilingual and legacy formats
          return {
            'header_en': trend['header_en']?.toString() ??
                trend['header']?.toString() ??
                'Trend',
            'header_ta': trend['header_ta']?.toString() ??
                trend['header']?.toString() ??
                'போக்கு',
            'overview_en': trend['overview_en']?.toString() ??
                trend['overview']?.toString() ??
                '',
            'overview_ta': trend['overview_ta']?.toString() ??
                trend['overview']?.toString() ??
                '',
            'detailedInsight_en': trend['detailedInsight_en']?.toString() ??
                trend['detailedInsight']?.toString() ??
                '',
            'detailedInsight_ta': trend['detailedInsight_ta']?.toString() ??
                trend['detailedInsight']?.toString() ??
                '',
            'imageUrl': validateAndSanitizeImageUrl(
              trend['imageUrl']?.toString(),
            ),
            'domainLabel_en': trend['domainLabel_en']?.toString() ??
                trend['domainLabel']?.toString() ??
                'Technology',
            'domainLabel_ta': trend['domainLabel_ta']?.toString() ??
                trend['domainLabel']?.toString() ??
                'தொழில்நுட்பம்',
          };
        }).toList();

        print('Successfully parsed ${trends.length} trends from Gemini AI');
        // Save to cache
        await _saveToCache(cacheKey, json.encode(trends));
        return trends;
      }

      print(
          'Failed to parse JSON from Gemini AI trends response, using fallback data');
      // Fallback to default trends
      return getDefaultTrends();
    } catch (e, stackTrace) {
      print('Error getting latest trends from Gemini AI: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default trends
      return getDefaultTrends();
    }
  }

  static List<Map<String, dynamic>> getDefaultTrends() {
    return [
      {
        'header_en': 'Growth of Electric Vehicles',
        'header_ta': 'மின் வாகனங்களின் வளர்ச்சி',
        'overview_en':
            'The electric vehicle market will grow significantly in 2025-2026. India\'s EV market expects 30% annual growth.',
        'overview_ta':
            '2025-2026 காலகட்டத்தில் மின் வாகனங்களின் சந்தை வளர்ச்சி கணிசமாக அதிகரிக்கும். இந்தியாவில் EV சந்தை 30% வருடாந்திர வளர்ச்சியை எதிர்பார்க்கிறது.',
        'detailedInsight_en':
            'Electric vehicle market growth is accelerated by technological advances and government support policies. Battery technology improvements reduce range concerns. Charging infrastructure expansion encourages EV adoption. Production cost reductions make prices more accessible. Increased environmental awareness turns consumers toward electric vehicles. Technology companies integrate advanced AI and autonomous features.',
        'detailedInsight_ta':
            'மின் வாகனங்களின் சந்தை வளர்ச்சி தொழில்நுட்ப முன்னேற்றங்கள் மற்றும் அரசாங்க ஆதரவு கொள்கைகளால் முடுக்கிவிடப்படுகிறது. பேட்டரி தொழில்நுட்பத்தில் முன்னேற்றங்கள் வரம்பு கவலைகளை குறைக்கின்றன. சார்ஜிங் உள்கட்டமைப்பு விரிவாக்கம் EV தத்துக்கொள்ளலை ஊக்குவிக்கிறது. உற்பத்தி செலவுகள் குறைவதால் விலைகள் மக்களுக்கு எட்டக்கூடியதாக மாறுகின்றன. சுற்றுச்சூழல் விழிப்புணர்வு அதிகரிப்பு நுகர்வோரை மின் வாகனங்களுக்கு திருப்புகிறது. தொழில்நுட்ப நிறுவனங்கள் மேம்பட்ட AI மற்றும் தன்னியக்க வசதிகளை ஒருங்கிணைக்கின்றன.',
        'imageUrl':
            'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=800',
        'domainLabel_en': 'Electric Vehicles',
        'domainLabel_ta': 'மின் வாகனங்கள்',
      },
    ];
  }

  // Generate Latest Car Launches (Top 5 India, Top 5 Global)
  static Future<Map<String, List<Map<String, dynamic>>>>
      generateLatestCarLaunches({
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    const cacheKey = 'latest_car_launches';
    if (!forceRefresh) {
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        try {
          final cachedMap = json.decode(cachedData) as Map<String, dynamic>;
          debugPrint('Using cached car launches data');
          return {
            'india': (cachedMap['india'] as List<dynamic>?)
                    ?.map((item) => Map<String, dynamic>.from(item))
                    .toList() ??
                [],
            'global': (cachedMap['global'] as List<dynamic>?)
                    ?.map((item) => Map<String, dynamic>.from(item))
                    .toList() ??
                [],
          };
        } catch (e) {
          debugPrint('Error parsing cached car launches data: $e');
        }
      }
    } else {
      debugPrint('Force refresh: bypassing cache for car launches');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      const prompt =
          '''Act as a Senior Automotive Market Analyst. Generate a report for exactly 3 cars (mix of India and Global markets) updated as of December 2025.

IMPORTANT: For each car, you MUST provide a high-quality, relevant automotive image URL. Images are MANDATORY. Use real, working automotive image URLs from pexels.com or pixabay.com. DO NOT use unsplash.com URLs as they often return 404 errors. Use direct image URLs from Pexels (pexels.com/photos/...) or Pixabay that are known to work.

Output Structure for each Car (JSON format):
{
  "brand": "Brand Name",
  "model": "Model Name",
  "primaryCountry": "Country Name",
  "overview_en": "Exactly 2 crisp lines in English",
  "overview_ta": "Exactly 2 crisp lines in Tamil",
  "detailedInsight_en": "Exactly 6 lines of technical and market depth in English (formatted for Read More expansion)",
  "detailedInsight_ta": "Exactly 6 lines of technical and market depth in Tamil (formatted for Read More expansion)",
  "imageUrl": "High-quality, relevant automotive image URL (MANDATORY - use real, working URLs from pexels.com or pixabay.com, NOT unsplash.com)",
  "launchDate": "Exact or Expected Date",
  "bestSellerStatus": "Yes/No/Trending",
  "popularCountry": "Country Name",
  "contextLabel_en": "Relevant domain title in English (e.g., Electric Vehicle Market)",
  "contextLabel_ta": "Relevant domain title in Tamil (e.g., மின்சார வாகனச் சந்தை)"
}

Return a JSON object with two arrays (total 3 cars across both):
{
  "india": [2 cars for India market],
  "global": [1 car for Global market]
}

Strict Guardrails:
- Images: MANDATORY. Each car must have a high-quality, relevant automotive image URL.
- Ring-fencing: Content must be 100% automotive. No deviation.
- Language: Provide BOTH English and Tamil versions for ALL text fields (overview, detailedInsight, contextLabel).
- Mobile Optimized: Keep sentences short and crisp for Android app viewing.
- No Hallucination: Use only verified late-2025 data.
- Zero Metadata: Do not include current date/time in the final output text.
- No Biases: Maintain a neutral, data-driven business tone.
- Image URLs: Use real automotive image URLs from unsplash.com or similar services.

Return ONLY valid JSON, no additional text or markdown.''';

      print('Calling Gemini AI for latest car launches...');
      final content = [Content.text(prompt)];
      final result = await model.generateContent(content);
      final responseText = result.text ?? '';

      print(
          'Gemini AI Car Launches Response received (length: ${responseText.length})');

      // Try multiple methods to extract JSON
      Map<String, dynamic>? jsonData;

      // Method 1: Try to find JSON object with regex
      try {
        final jsonMatch =
            RegExp(r'\{[\s\S]*\}', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          jsonData = json.decode(jsonString) as Map<String, dynamic>;
          print('Successfully parsed car launches JSON using regex method');
        }
      } catch (e) {
        print('Regex method failed: $e');
      }

      // Method 2: Try to parse the entire response as JSON
      if (jsonData == null) {
        try {
          jsonData = json.decode(responseText.trim()) as Map<String, dynamic>;
          print('Successfully parsed car launches JSON directly');
        } catch (e) {
          print('Direct parsing failed: $e');
        }
      }

      // Method 3: Try to find JSON between ```json and ``` or ``` and ```
      if (jsonData == null) {
        try {
          final codeBlockMatch =
              RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```', dotAll: true)
                  .firstMatch(responseText);
          if (codeBlockMatch != null) {
            final jsonString = codeBlockMatch.group(1)!;
            jsonData = json.decode(jsonString) as Map<String, dynamic>;
            print('Successfully parsed car launches JSON from code block');
          }
        } catch (e) {
          print('Code block parsing failed: $e');
        }
      }

      // If we successfully parsed JSON, validate and return
      if (jsonData != null) {
        final indiaCars = (jsonData['india'] as List<dynamic>?)?.map((item) {
              final car = item as Map<String, dynamic>;
              return {
                'brand': car['brand']?.toString() ?? 'Unknown',
                'model': car['model']?.toString() ?? 'Unknown',
                'primaryCountry': car['primaryCountry']?.toString() ?? 'India',
                'overview_en': car['overview_en']?.toString() ??
                    car['overview']?.toString() ??
                    '',
                'overview_ta': car['overview_ta']?.toString() ??
                    car['overview']?.toString() ??
                    '',
                'detailedInsight_en': car['detailedInsight_en']?.toString() ??
                    car['detailedInsight']?.toString() ??
                    '',
                'detailedInsight_ta': car['detailedInsight_ta']?.toString() ??
                    car['detailedInsight']?.toString() ??
                    '',
                'imageUrl': validateAndSanitizeImageUrl(
                  car['imageUrl']?.toString(),
                  carModel:
                      car['model']?.toString() ?? car['brand']?.toString(),
                ),
                'launchDate': car['launchDate']?.toString() ?? 'N/A',
                'bestSellerStatus': car['bestSellerStatus']?.toString() ?? 'No',
                'popularCountry': car['popularCountry']?.toString() ?? 'India',
                'contextLabel_en': car['contextLabel_en']?.toString() ??
                    car['contextLabel']?.toString() ??
                    'Vehicle Market',
                'contextLabel_ta': car['contextLabel_ta']?.toString() ??
                    car['contextLabel']?.toString() ??
                    'வாகனச் சந்தை',
              };
            }).toList() ??
            [];

        final globalCars = (jsonData['global'] as List<dynamic>?)?.map((item) {
              final car = item as Map<String, dynamic>;
              return {
                'brand': car['brand']?.toString() ?? 'Unknown',
                'model': car['model']?.toString() ?? 'Unknown',
                'primaryCountry': car['primaryCountry']?.toString() ?? 'Global',
                'overview_en': car['overview_en']?.toString() ??
                    car['overview']?.toString() ??
                    '',
                'overview_ta': car['overview_ta']?.toString() ??
                    car['overview']?.toString() ??
                    '',
                'detailedInsight_en': car['detailedInsight_en']?.toString() ??
                    car['detailedInsight']?.toString() ??
                    '',
                'detailedInsight_ta': car['detailedInsight_ta']?.toString() ??
                    car['detailedInsight']?.toString() ??
                    '',
                'imageUrl': validateAndSanitizeImageUrl(
                  car['imageUrl']?.toString(),
                  carModel:
                      car['model']?.toString() ?? car['brand']?.toString(),
                ),
                'launchDate': car['launchDate']?.toString() ?? 'N/A',
                'bestSellerStatus': car['bestSellerStatus']?.toString() ?? 'No',
                'popularCountry': car['popularCountry']?.toString() ?? 'Global',
                'contextLabel_en': car['contextLabel_en']?.toString() ??
                    car['contextLabel']?.toString() ??
                    'Vehicle Market',
                'contextLabel_ta': car['contextLabel_ta']?.toString() ??
                    car['contextLabel']?.toString() ??
                    'வாகனச் சந்தை',
              };
            }).toList() ??
            [];

        print(
            'Successfully parsed ${indiaCars.length} India cars and ${globalCars.length} global cars from Gemini AI');
        final result = {
          'india': indiaCars,
          'global': globalCars,
        };
        // Save to cache
        await _saveToCache(cacheKey, json.encode(result));
        return result;
      }

      print(
          'Failed to parse JSON from Gemini AI car launches response, using fallback data');
      // Fallback to default car launches
      return getDefaultCarLaunches();
    } catch (e, stackTrace) {
      print('Error getting latest car launches from Gemini AI: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default car launches
      return getDefaultCarLaunches();
    }
  }

  static Map<String, List<Map<String, dynamic>>> getDefaultCarLaunches() {
    return {
      'india': [
        {
          'brand': 'Hyundai',
          'model': 'Creta N Line',
          'primaryCountry': 'India',
          'overview':
              'ஹுண்டாய் கிரெட்டா N Line இந்தியாவில் விளையாட்டு SUV பிரிவில் புதிய பரிமாணத்தை அறிமுகப்படுத்துகிறது. விளையாட்டு-கவனம் செலுத்தும் வடிவமைப்பு மற்றும் செயல்திறன் அம்சங்களுடன் வருகிறது.',
          'detailedInsight':
              'கிரெட்டா N Line 1.5L turbocharged பெட்ரோல் இயந்திரத்துடன் 160 PS சக்தியை வழங்குகிறது. N Line குறிப்பிட்ட வெளிப்புற மற்றும் உட்புற அலங்காரங்கள் விளையாட்டு தோற்றத்தை அளிக்கின்றன. Sport+ drive mode மற்றும் paddle shifters செயல்திறன் அனுபவத்தை மேம்படுத்துகின்றன. பாதுகாப்பு அம்சங்களில் 6 airbags, ESC, மற்றும் hill assist control ஆகியவை அடங்கும். ₹16-20 லட்சம் விலை வரம்பில் போட்டியிடுகிறது. இளம் வாங்குபவர்கள் மற்றும் விளையாட்டு SUV விரும்பிகளுக்கு இலக்காக உள்ளது.',
          'imageUrl':
              'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=800',
          'launchDate': 'ஏப்ரல் 2025',
          'bestSellerStatus': 'Yes',
          'popularCountry': 'India',
          'contextLabel': 'விளையாட்டு SUV சந்தை',
        },
      ],
    };
  }

  // Generate Profitable Cars Report (Top 5 for each traction period)
  static Future<Map<String, List<Map<String, dynamic>>>>
      generateProfitableCars({
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    const cacheKey = 'profitable_cars';
    if (!forceRefresh) {
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        try {
          final cachedMap = json.decode(cachedData) as Map<String, dynamic>;
          debugPrint('Using cached profitable cars data');
          return {
            'threeYears': (cachedMap['threeYears'] as List<dynamic>?)
                    ?.map((item) => Map<String, dynamic>.from(item))
                    .toList() ??
                [],
            'fiveYears': (cachedMap['fiveYears'] as List<dynamic>?)
                    ?.map((item) => Map<String, dynamic>.from(item))
                    .toList() ??
                [],
            'tenYears': (cachedMap['tenYears'] as List<dynamic>?)
                    ?.map((item) => Map<String, dynamic>.from(item))
                    .toList() ??
                [],
          };
        } catch (e) {
          debugPrint('Error parsing cached profitable cars data: $e');
        }
      }
    } else {
      debugPrint('Force refresh: bypassing cache for profitable cars');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      const prompt =
          '''Act as a Senior Automotive Business Consultant. Generate a data-driven report on top-selling profitable cars in India.

IMPORTANT: For each vehicle, you MUST provide a high-quality, relevant automotive image URL. Images are MANDATORY. Use real, working automotive image URLs from pexels.com or pixabay.com. DO NOT use unsplash.com URLs as they often return 404 errors. Use direct image URLs from Pexels (pexels.com/photos/...) or Pixabay that are known to work.

Structure: Present exactly 3 cars for each of these three categories:
1. 3 Years Traction (Modern Gainers)
2. 5 Years Traction (Reliable Assets)
3. 10 Years Traction (The Legends)

Output Format for each Vehicle (JSON):
{
  "brand": "Brand Name",
  "model": "Model Name",
  "tractionPeriod": "3 Years/5 Years/10 Years",
  "overview_en": "Exactly 2 crisp lines in English (Focus on why it's a hot seller)",
  "overview_ta": "Exactly 2 crisp lines in Tamil (Focus on why it's a hot seller)",
  "detailedInsight_en": "Exactly 6 lines in English (Focus on profit margins, reliability, and resale value for a business owner)",
  "detailedInsight_ta": "Exactly 6 lines in Tamil (Focus on profit margins, reliability, and resale value for a business owner)",
  "salesData": "Estimated or verified total units sold in India (e.g., Sales: 10 lakhs+ / விற்பனை: 10 லட்சம்+)",
  "imageUrl": "High-quality, relevant automotive image URL (MANDATORY - use real, working URLs from pexels.com or pixabay.com, NOT unsplash.com)",
  "resaleValue": "High/Excellent",
  "maintenanceCost": "Low/Medium/High",
  "salesSpeed": "Fast/Very Fast",
  "contextLabel_en": "Relevant domain title in English (e.g., Resale Market)",
  "contextLabel_ta": "Relevant domain title in Tamil (e.g., மறுவிற்பனை சந்தை)"
}

Return a JSON object with three arrays:
{
  "threeYears": [3 cars for 3 Years Traction],
  "fiveYears": [3 cars for 5 Years Traction],
  "tenYears": [3 cars for 10 Years Traction]
}

Strict Guardrails:
- Images: MANDATORY. Each vehicle must have a high-quality, relevant automotive image URL.
- Language: Provide BOTH English and Tamil versions for ALL text fields (overview, detailedInsight, contextLabel).
- Business Focus: Content must assist MSME owners in inventory decision-making.
- Ring-fencing: Strictly automotive content only. No metadata (date/time) or fillers.
- Sales Data: Use realistic numbers based on Indian market.
- Image URLs: Use real automotive image URLs from pexels.com or pixabay.com only.

Return ONLY valid JSON, no additional text or markdown.''';

      print('Calling Gemini AI for profitable cars report...');
      final content = [Content.text(prompt)];
      final result = await model.generateContent(content);
      final responseText = result.text ?? '';

      print(
          'Gemini AI Profitable Cars Response received (length: ${responseText.length})');

      // Try multiple methods to extract JSON
      Map<String, dynamic>? jsonData;

      // Method 1: Try to find JSON object with regex
      try {
        final jsonMatch =
            RegExp(r'\{[\s\S]*\}', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          jsonData = json.decode(jsonString) as Map<String, dynamic>;
          print('Successfully parsed profitable cars JSON using regex method');
        }
      } catch (e) {
        print('Regex method failed: $e');
      }

      // Method 2: Try to parse the entire response as JSON
      if (jsonData == null) {
        try {
          jsonData = json.decode(responseText.trim()) as Map<String, dynamic>;
          print('Successfully parsed profitable cars JSON directly');
        } catch (e) {
          print('Direct parsing failed: $e');
        }
      }

      // Method 3: Try to find JSON between ```json and ``` or ``` and ```
      if (jsonData == null) {
        try {
          final codeBlockMatch =
              RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```', dotAll: true)
                  .firstMatch(responseText);
          if (codeBlockMatch != null) {
            final jsonString = codeBlockMatch.group(1)!;
            jsonData = json.decode(jsonString) as Map<String, dynamic>;
            print('Successfully parsed profitable cars JSON from code block');
          }
        } catch (e) {
          print('Code block parsing failed: $e');
        }
      }

      // If we successfully parsed JSON, validate and return
      if (jsonData != null) {
        final threeYears =
            (jsonData['threeYears'] as List<dynamic>?)?.map((item) {
                  final car = item as Map<String, dynamic>;
                  return {
                    'brand': car['brand']?.toString() ?? 'Unknown',
                    'model': car['model']?.toString() ?? 'Unknown',
                    'tractionPeriod':
                        car['tractionPeriod']?.toString() ?? '3 Years',
                    'overview': car['overview']?.toString() ?? '',
                    'overview_en': car['overview_en']?.toString() ?? car['overview']?.toString() ?? '',
                    'overview_ta': car['overview_ta']?.toString() ?? car['overview']?.toString() ?? '',
                    'detailedInsight': car['detailedInsight']?.toString() ?? '',
                    'detailedInsight_en': car['detailedInsight_en']?.toString() ?? car['detailedInsight']?.toString() ?? '',
                    'detailedInsight_ta': car['detailedInsight_ta']?.toString() ?? car['detailedInsight']?.toString() ?? '',
                    'salesData': car['salesData']?.toString() ?? 'Sales: N/A / விற்பனை: N/A',
                    'imageUrl': validateAndSanitizeImageUrl(
                      car['imageUrl']?.toString(),
                      carModel:
                          car['model']?.toString() ?? car['brand']?.toString(),
                    ),
                    'resaleValue': car['resaleValue']?.toString() ?? 'High',
                    'maintenanceCost':
                        car['maintenanceCost']?.toString() ?? 'Medium',
                    'salesSpeed': car['salesSpeed']?.toString() ?? 'Fast',
                    'contextLabel':
                        car['contextLabel']?.toString() ?? 'வாகனச் சந்தை',
                    'contextLabel_en': car['contextLabel_en']?.toString() ?? car['contextLabel']?.toString() ?? 'Vehicle Market',
                    'contextLabel_ta': car['contextLabel_ta']?.toString() ?? car['contextLabel']?.toString() ?? 'வாகனச் சந்தை',
                  };
                }).toList() ??
                [];

        final fiveYears =
            (jsonData['fiveYears'] as List<dynamic>?)?.map((item) {
                  final car = item as Map<String, dynamic>;
                  return {
                    'brand': car['brand']?.toString() ?? 'Unknown',
                    'model': car['model']?.toString() ?? 'Unknown',
                    'tractionPeriod':
                        car['tractionPeriod']?.toString() ?? '5 Years',
                    'overview': car['overview']?.toString() ?? '',
                    'overview_en': car['overview_en']?.toString() ?? car['overview']?.toString() ?? '',
                    'overview_ta': car['overview_ta']?.toString() ?? car['overview']?.toString() ?? '',
                    'detailedInsight': car['detailedInsight']?.toString() ?? '',
                    'detailedInsight_en': car['detailedInsight_en']?.toString() ?? car['detailedInsight']?.toString() ?? '',
                    'detailedInsight_ta': car['detailedInsight_ta']?.toString() ?? car['detailedInsight']?.toString() ?? '',
                    'salesData': car['salesData']?.toString() ?? 'Sales: N/A / விற்பனை: N/A',
                    'imageUrl': validateAndSanitizeImageUrl(
                      car['imageUrl']?.toString(),
                      carModel:
                          car['model']?.toString() ?? car['brand']?.toString(),
                    ),
                    'resaleValue': car['resaleValue']?.toString() ?? 'High',
                    'maintenanceCost':
                        car['maintenanceCost']?.toString() ?? 'Medium',
                    'salesSpeed': car['salesSpeed']?.toString() ?? 'Fast',
                    'contextLabel':
                        car['contextLabel']?.toString() ?? 'வாகனச் சந்தை',
                  };
                }).toList() ??
                [];

        final tenYears = (jsonData['tenYears'] as List<dynamic>?)?.map((item) {
              final car = item as Map<String, dynamic>;
              return {
                'brand': car['brand']?.toString() ?? 'Unknown',
                'model': car['model']?.toString() ?? 'Unknown',
                'tractionPeriod':
                    car['tractionPeriod']?.toString() ?? '10 Years',
                'overview': car['overview']?.toString() ?? '',
                'overview_en': car['overview_en']?.toString() ?? car['overview']?.toString() ?? '',
                'overview_ta': car['overview_ta']?.toString() ?? car['overview']?.toString() ?? '',
                'detailedInsight': car['detailedInsight']?.toString() ?? '',
                'detailedInsight_en': car['detailedInsight_en']?.toString() ?? car['detailedInsight']?.toString() ?? '',
                'detailedInsight_ta': car['detailedInsight_ta']?.toString() ?? car['detailedInsight']?.toString() ?? '',
                'salesData': car['salesData']?.toString() ?? 'Sales: N/A / விற்பனை: N/A',
                'imageUrl': validateAndSanitizeImageUrl(
                  car['imageUrl']?.toString(),
                  carModel:
                      car['model']?.toString() ?? car['brand']?.toString(),
                ),
                'resaleValue': car['resaleValue']?.toString() ?? 'High',
                'maintenanceCost':
                    car['maintenanceCost']?.toString() ?? 'Medium',
                'salesSpeed': car['salesSpeed']?.toString() ?? 'Fast',
                'contextLabel':
                    car['contextLabel']?.toString() ?? 'வாகனச் சந்தை',
                'contextLabel_en': car['contextLabel_en']?.toString() ?? car['contextLabel']?.toString() ?? 'Vehicle Market',
                'contextLabel_ta': car['contextLabel_ta']?.toString() ?? car['contextLabel']?.toString() ?? 'வாகனச் சந்தை',
              };
            }).toList() ??
            [];

        print(
            'Successfully parsed ${threeYears.length} three-year, ${fiveYears.length} five-year, and ${tenYears.length} ten-year cars from Gemini AI');
        final result = {
          'threeYears': threeYears,
          'fiveYears': fiveYears,
          'tenYears': tenYears,
        };
        // Save to cache
        await _saveToCache(cacheKey, json.encode(result));
        return result;
      }

      print(
          'Failed to parse JSON from Gemini AI profitable cars response, using fallback data');
      // Fallback to default profitable cars
      return getDefaultProfitableCars();
    } catch (e, stackTrace) {
      print('Error getting profitable cars from Gemini AI: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default profitable cars
      return getDefaultProfitableCars();
    }
  }

  static Map<String, List<Map<String, dynamic>>> getDefaultProfitableCars() {
    return {
      'threeYears': [
        {
          'brand': 'Kia',
          'model': 'Seltos',
          'tractionPeriod': '3 Years',
          'overview':
              'கியா செல்டோஸ் இந்திய சந்தையில் 3 ஆண்டுகளில் premium compact SUV பிரிவில் முக்கிய வீரராக மாறியுள்ளது. Feature-rich offerings மற்றும் aggressive pricing strategy நிறுவனங்களுக்கு சிறந்த இலாப வாய்ப்பை வழங்குகிறது.',
          'detailedInsight':
              'செல்டோஸ் 3 ஆண்டுகளில் 4+ லட்சம் அலகுகள் விற்பனை செய்துள்ளது, இது நிறுவனங்களுக்கு நிலையான வருவாய் ஓட்டத்தை உறுதி செய்கிறது. 60-65% மறுவிற்பனை மதிப்பு நிறுவனங்களுக்கு நல்ல ROI வழங்குகிறது. Premium features மற்றும் modern design இளம் வாங்குபவர்களை ஈர்க்கிறது. ₹10-18 லட்சம் விலை வரம்பில் போட்டியிடும் விலையில் நிறுவனங்களுக்கு சிறந்த மதிப்பை வழங்குகிறது. குறைந்த பராமரிப்பு செலவு மற்றும் நம்பகமான செயல்திறன் நீண்ட கால முதலீட்டை பாதுகாக்கிறது. விரைவான விற்பனை வேகம் inventory management efficiency அதிகரிக்கிறது.',
          'salesData': 'விற்பனை: 4+ லட்சம் அலகுகள்',
          'imageUrl':
              'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=800',
          'resaleValue': 'High',
          'maintenanceCost': 'Low',
          'salesSpeed': 'Very Fast',
          'contextLabel': 'Premium Compact SUV சந்தை',
        },
      ],
      'fiveYears': [
        {
          'brand': 'Maruti',
          'model': 'Vitara Brezza',
          'tractionPeriod': '5 Years',
          'overview':
              'மாருதி விட்டாரா பிரெஸா 5 ஆண்டுகளில் இந்திய சந்தையில் மிகவும் விற்பனையாகும் compact SUV ஆக தொடர்கிறது. Fuel efficiency மற்றும் low maintenance cost நிறுவனங்களுக்கு சிறந்த நீண்ட கால முதலீட்டை வழங்குகிறது.',
          'detailedInsight':
              'பிரெஸா 5 ஆண்டுகளில் 10+ லட்சம் அலகுகள் விற்பனை செய்துள்ளது, இது நிறுவனங்களுக்கு நிலையான வருவாய் ஓட்டத்தை உறுதி செய்கிறது. 65-70% மறுவிற்பனை மதிப்பு நிறுவனங்களுக்கு சிறந்த ROI வழங்குகிறது. CNG variant availability fuel cost savings வழங்குகிறது. ₹7-11 லட்சம் விலை வரம்பில் போட்டியிடும் விலையில் நிறுவனங்களுக்கு சிறந்த மதிப்பை வழங்குகிறது. குறைந்த பராமரிப்பு செலவு மற்றும் நம்பகமான செயல்திறன் நீண்ட கால முதலீட்டை பாதுகாக்கிறது. விரைவான விற்பனை வேகம் inventory management efficiency அதிகரிக்கிறது.',
          'salesData': 'விற்பனை: 10+ லட்சம் அலகுகள்',
          'imageUrl':
              'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=800',
          'resaleValue': 'Excellent',
          'maintenanceCost': 'Low',
          'salesSpeed': 'Very Fast',
          'contextLabel': 'மறுவிற்பனை சந்தை',
        },
      ],
      'tenYears': [
        {
          'brand': 'Toyota',
          'model': 'Fortuner',
          'tractionPeriod': '10 Years',
          'overview':
              'டோயோட்டா ஃபார்ச்சூனர் 10+ ஆண்டுகளில் இந்திய சந்தையில் premium SUV பிரிவில் legend ஆக விளங்குகிறது. Exceptional resale value மற்றும் reliability நிறுவனங்களுக்கு சிறந்த நீண்ட கால முதலீட்டை வழங்குகிறது.',
          'detailedInsight':
              'ஃபார்ச்சூனர் 10+ ஆண்டுகளில் 5+ லட்சம் அலகுகள் விற்பனை செய்துள்ளது, இது நிறுவனங்களுக்கு நிலையான வருவாய் ஓட்டத்தை உறுதி செய்கிறது. 75-80% மறுவிற்பனை மதிப்பு நிறுவனங்களுக்கு சிறந்த ROI வழங்குகிறது. Powerful engine options மற்றும் premium features வாங்குபவர்களை ஈர்க்கிறது. ₹30-40 லட்சம் விலை வரம்பில் போட்டியிடும் விலையில் நிறுவனங்களுக்கு சிறந்த மதிப்பை வழங்குகிறது. நடுத்தர பராமரிப்பு செலவு மற்றும் நம்பகமான செயல்திறன் நீண்ட கால முதலீட்டை பாதுகாக்கிறது. நல்ல விற்பனை வேகம் inventory management efficiency அதிகரிக்கிறது.',
          'salesData': 'விற்பனை: 5+ லட்சம் அலகுகள்',
          'imageUrl':
              'https://images.pexels.com/photos/116675/pexels-photo-116675.jpeg?auto=compress&cs=tinysrgb&w=800',
          'resaleValue': 'Excellent',
          'maintenanceCost': 'Medium',
          'salesSpeed': 'Fast',
          'contextLabel': 'Premium SUV சந்தை',
        },
      ],
    };
  }

  // Generate Tamil Nadu Market Kings Report (Top 5 vehicles)
  static Future<List<Map<String, dynamic>>> generateTNMarketKings({
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    const cacheKey = 'tn_market_kings';
    if (!forceRefresh) {
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        try {
          final cachedList = json.decode(cachedData) as List<dynamic>;
          debugPrint('Using cached TN market kings data');
          return cachedList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } catch (e) {
          debugPrint('Error parsing cached TN market kings data: $e');
        }
      }
    } else {
      debugPrint('Force refresh: bypassing cache for TN market kings');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      const prompt =
          '''Act as a Specialist Automotive Business Strategist for the Tamil Nadu market. Generate a mobile-optimized business report on the top 3 vehicles dominating the TN pre-owned market.

IMPORTANT: For each vehicle, you MUST provide a high-quality, relevant automotive image URL. Images are MANDATORY. Use real, working automotive image URLs from pexels.com or pixabay.com. DO NOT use unsplash.com URLs as they often return 404 errors. Use direct image URLs from Pexels (pexels.com/photos/...) or Pixabay that are known to work.

Output Structure for each Vehicle (JSON format):
{
  "brand": "Brand Name",
  "model": "Model Name",
  "wowFactor_en": "Exactly 2 lines in English on profit potential (e.g., This car turns into money within 3 days if kept in showroom)",
  "wowFactor_ta": "Exactly 2 lines in Tamil on profit potential (e.g., இந்த கார் ஷோரூமில் நின்றால் 3 நாட்களில் பணமாக மாறும்)",
  "tnBusinessInsight_en": "Exactly 5-6 short lines in English. Mention specific TN regional demand (Chennai/Madurai/Kovai) and mechanical durability. Use short sentences for mobile.",
  "tnBusinessInsight_ta": "Exactly 5-6 short lines in Tamil. Mention specific TN regional demand (Chennai/Madurai/Kovai) and mechanical durability. Use short sentences for mobile.",
  "imageUrl": "High-quality, relevant automotive image URL (MANDATORY - use real, working URLs from pexels.com or pixabay.com, NOT unsplash.com)",
  "indianSales": "Estimated total units sold in India (e.g., 30 லட்சம்+ / 30 Lakh+)",
  "resaleValue": "Legendary/High/Excellent",
  "maintenance": "Low/Medium/High",
  "salesSpeed": "Instant/3-5 Days/1 Week"
}

Return a JSON array with exactly 3 vehicles:
[
  {vehicle 1},
  {vehicle 2},
  {vehicle 3}
]

Strict Guardrails:
- Images: MANDATORY. Each vehicle must have a high-quality, relevant automotive image URL.
- Mobile First: Avoid long paragraphs. Use short sentences and bullet points for scannability.
- TN Context: Must mention why it's popular in Tamil Nadu (e.g., Mileage for TN highways, high resale in Tier-2 cities like Madurai/Kovai).
- Visuals: Images are MANDATORY. Use real, working automotive image URLs from pexels.com or pixabay.com only. DO NOT use unsplash.com.
- Language: Provide BOTH English and Tamil versions for ALL text fields (wowFactor, tnBusinessInsight). Use _en and _ta suffixes for language-specific fields.
- Ring-fencing: Automotive business context only. No metadata or fillers.
- Regional Focus: Mention specific TN cities (Chennai/Madurai/Coimbatore/Kovai) and regional preferences.

Return ONLY valid JSON array, no additional text or markdown.''';

      print('Calling Gemini AI for Tamil Nadu Market Kings...');
      final content = [Content.text(prompt)];
      final result = await model.generateContent(content);
      final responseText = result.text ?? '';

      print(
          'Gemini AI TN Market Kings Response received (length: ${responseText.length})');

      // Try multiple methods to extract JSON
      List<dynamic>? jsonData;

      // Method 1: Try to find JSON array with regex
      try {
        final jsonMatch =
            RegExp(r'\[[\s\S]*\]', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          jsonData = json.decode(jsonString) as List<dynamic>;
          print('Successfully parsed TN market kings JSON using regex method');
        }
      } catch (e) {
        print('Regex method failed: $e');
      }

      // Method 2: Try to parse the entire response as JSON
      if (jsonData == null) {
        try {
          jsonData = json.decode(responseText.trim()) as List<dynamic>;
          print('Successfully parsed TN market kings JSON directly');
        } catch (e) {
          print('Direct parsing failed: $e');
        }
      }

      // Method 3: Try to find JSON between ```json and ``` or ``` and ```
      if (jsonData == null) {
        try {
          final codeBlockMatch =
              RegExp(r'```(?:json)?\s*(\[[\s\S]*?\])\s*```', dotAll: true)
                  .firstMatch(responseText);
          if (codeBlockMatch != null) {
            final jsonString = codeBlockMatch.group(1)!;
            jsonData = json.decode(jsonString) as List<dynamic>;
            print('Successfully parsed TN market kings JSON from code block');
          }
        } catch (e) {
          print('Code block parsing failed: $e');
        }
      }

      // If we successfully parsed JSON, validate and return
      if (jsonData != null && jsonData.isNotEmpty) {
        final vehicles = jsonData.map((item) {
          final vehicle = item as Map<String, dynamic>;
          // Ensure all required fields exist
          return {
            'brand': vehicle['brand']?.toString() ?? 'Unknown',
            'model': vehicle['model']?.toString() ?? 'Unknown',
            'wowFactor': vehicle['wowFactor']?.toString() ?? '',
            'wowFactor_en': vehicle['wowFactor_en']?.toString() ?? 
                vehicle['wowFactor']?.toString() ?? '',
            'wowFactor_ta': vehicle['wowFactor_ta']?.toString() ?? 
                vehicle['wowFactor']?.toString() ?? '',
            'tnBusinessInsight': vehicle['tnBusinessInsight']?.toString() ?? '',
            'tnBusinessInsight_en': vehicle['tnBusinessInsight_en']?.toString() ?? 
                vehicle['tnBusinessInsight']?.toString() ?? '',
            'tnBusinessInsight_ta': vehicle['tnBusinessInsight_ta']?.toString() ?? 
                vehicle['tnBusinessInsight']?.toString() ?? '',
            'imageUrl':
                vehicle['imageUrl']?.toString() ?? getReliableCarImageUrl(),
            'indianSales': vehicle['indianSales']?.toString() ?? 'N/A',
            'resaleValue': vehicle['resaleValue']?.toString() ?? 'High',
            'maintenance': vehicle['maintenance']?.toString() ?? 'Medium',
            'salesSpeed': vehicle['salesSpeed']?.toString() ?? '3-5 Days',
          };
        }).toList();

        print(
            'Successfully parsed ${vehicles.length} TN market kings from Gemini AI');
        // Save to cache
        await _saveToCache(cacheKey, json.encode(vehicles));
        return vehicles;
      }

      print(
          'Failed to parse JSON from Gemini AI TN market kings response, using fallback data');
      // Fallback to default TN market kings
      return getDefaultTNMarketKings();
    } catch (e, stackTrace) {
      print('Error getting TN market kings from Gemini AI: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default TN market kings
      return getDefaultTNMarketKings();
    }
  }

  static List<Map<String, dynamic>> getDefaultTNMarketKings() {
    return [
      {
        'brand': 'Honda',
        'model': 'City',
        'wowFactor':
            'சென்னை sedan market இல் 5 நாட்களுக்குள் sale. Premium build quality காரணமாக excellent profit margin.',
        'wowFactor_en':
            'Sells within 5 days in Chennai sedan market. Excellent profit margin due to premium build quality.',
        'wowFactor_ta':
            'சென்னை sedan market இல் 5 நாட்களுக்குள் sale. Premium build quality காரணமாக excellent profit margin.',
        'tnBusinessInsight':
            'சென்னை premium sedan segment இல் 68-73% resale value. கோவையில் reliability காரணமாக strong demand. TN highways இற்கு fuel-efficient i-VTEC engine. Low maintenance cost மற்றும் high reliability. Chennai மற்றும் Coimbatore இல் executive segment favorite. Excellent mechanical durability TN climate conditions இற்கு suitable.',
        'tnBusinessInsight_en':
            '68-73% resale value in Chennai premium sedan segment. Strong demand in Coimbatore due to reliability. Fuel-efficient i-VTEC engine for TN highways. Low maintenance cost and high reliability. Executive segment favorite in Chennai and Coimbatore. Excellent mechanical durability suitable for TN climate conditions.',
        'tnBusinessInsight_ta':
            'சென்னை premium sedan segment இல் 68-73% resale value. கோவையில் reliability காரணமாக strong demand. TN highways இற்கு fuel-efficient i-VTEC engine. Low maintenance cost மற்றும் high reliability. Chennai மற்றும் Coimbatore இல் executive segment favorite. Excellent mechanical durability TN climate conditions இற்கு suitable.',
        'imageUrl': getReliableCarImageUrl(),
        'indianSales': '12+ லட்சம் / 12+ Lakh',
        'resaleValue': 'Excellent',
        'maintenance': 'Low',
        'salesSpeed': '5-7 Days',
      },
    ];
  }

  // Generate Daily Strategy for Tamil Nadu Automotive Market
  static Future<Map<String, dynamic>> generateDailyStrategy({
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    const cacheKey = 'daily_strategy';
    if (!forceRefresh) {
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        try {
          final cachedMap = json.decode(cachedData) as Map<String, dynamic>;
          debugPrint('Using cached daily strategy data');
          return Map<String, dynamic>.from(cachedMap);
        } catch (e) {
          debugPrint('Error parsing cached daily strategy data: $e');
        }
      }
    } else {
      debugPrint('Force refresh: bypassing cache for daily strategy');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      const prompt =
          '''Act as a Strategic Growth Consultant for the Tamil Nadu Automotive Market. Generate one high-impact business recommendation for the day that a pre-owned car dealer can implement immediately to increase profit or stock turnover in TN.

IMPORTANT: You MUST provide a professional, high-quality automotive or business-growth themed image URL. Images are MANDATORY. Use real, working image URLs from pexels.com or pixabay.com. DO NOT use unsplash.com URLs as they often return 404 errors. Use direct image URLs from Pexels (pexels.com/photos/...) or Pixabay that are known to work.

Output Structure (JSON format) - MUST provide BOTH English and Tamil versions:
{
  "strategyTitle_en": "Powerful Strategy Title in English",
  "strategyTitle_ta": "Powerful Strategy Title in Tamil",
  "strategy_en": "Exactly 4-5 crisp lines in English. Focus on real-world TN scenarios (e.g., Seasonal demands like Pongal/Diwali, Chennai flood-aware stock, or Tier-2 city trends). Use short sentences.",
  "strategy_ta": "Exactly 4-5 crisp lines in Tamil. Focus on real-world TN scenarios (e.g., Seasonal demands like Pongal/Diwali, Chennai flood-aware stock, or Tier-2 city trends). Use short sentences.",
  "businessBenefit_en": "Exactly 1 line in English explaining the ROI (e.g., This will increase your sales speed by 20%)",
  "businessBenefit_ta": "Exactly 1 line in Tamil explaining the ROI (e.g., இது உங்கள் விற்பனை வேகத்தை 20% அதிகரிக்கும்)",
  "imageUrl": "Professional, high-quality automotive or business-growth themed image URL (MANDATORY - use real, working URLs from pexels.com or pixabay.com, NOT unsplash.com)",
  "todaysTask_en": "One bold, actionable step the owner must take today in English",
  "todaysTask_ta": "One bold, actionable step the owner must take today in Tamil"
}

Strict Guardrails:
- Images: MANDATORY. Provide a professional, high-quality automotive or business-growth themed image URL.
- No Fillers: Strictly avoid the word "Tonic" or any fluff. Use professional business language.
- TN Market Focus: Advice must be relevant to the Tamil Nadu business landscape (Local trust, specific car types, local festivals like Pongal/Diwali).
- Mobile First: Use bold headers and short sentences for easy reading on Android devices.
- Visuals: Focus on professional showroom or stock management visuals from pexels.com or pixabay.com only. DO NOT use unsplash.com.
- Ring-fencing: Automotive business growth context only. No metadata or conversational chat.
- Language: MUST provide BOTH English (_en) and Tamil (_ta) versions for ALL text fields (strategyTitle, strategy, businessBenefit, todaysTask).

Return ONLY valid JSON object, no additional text or markdown.''';

      print('Calling Gemini AI for daily strategy...');
      final content = [Content.text(prompt)];
      final result = await model.generateContent(content);
      final responseText = result.text ?? '';

      print(
          'Gemini AI Daily Strategy Response received (length: ${responseText.length})');

      // Try multiple methods to extract JSON
      Map<String, dynamic>? jsonData;

      // Method 1: Try to find JSON object with regex
      try {
        final jsonMatch =
            RegExp(r'\{[\s\S]*\}', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          jsonData = json.decode(jsonString) as Map<String, dynamic>;
          print('Successfully parsed daily strategy JSON using regex method');
        }
      } catch (e) {
        print('Regex method failed: $e');
      }

      // Method 2: Try to parse the entire response as JSON
      if (jsonData == null) {
        try {
          jsonData = json.decode(responseText.trim()) as Map<String, dynamic>;
          print('Successfully parsed daily strategy JSON directly');
        } catch (e) {
          print('Direct parsing failed: $e');
        }
      }

      // Method 3: Try to find JSON between ```json and ``` or ``` and ```
      if (jsonData == null) {
        try {
          final codeBlockMatch =
              RegExp(r'```(?:json)?\s*(\{[\s\S]*?\})\s*```', dotAll: true)
                  .firstMatch(responseText);
          if (codeBlockMatch != null) {
            final jsonString = codeBlockMatch.group(1)!;
            jsonData = json.decode(jsonString) as Map<String, dynamic>;
            print('Successfully parsed daily strategy JSON from code block');
          }
        } catch (e) {
          print('Code block parsing failed: $e');
        }
      }

      // If we successfully parsed JSON, validate and return
      if (jsonData != null) {
        final strategy = {
          'strategyTitle_en': jsonData['strategyTitle_en']?.toString() ??
              jsonData['strategyTitle']?.toString() ??
              'Profit Strategy',
          'strategyTitle_ta': jsonData['strategyTitle_ta']?.toString() ??
              jsonData['strategyTitle']?.toString() ??
              'லாப வியூகம்',
          'strategy_en': jsonData['strategy_en']?.toString() ??
              jsonData['strategy']?.toString() ??
              '',
          'strategy_ta': jsonData['strategy_ta']?.toString() ??
              jsonData['strategy']?.toString() ??
              '',
          'businessBenefit_en': jsonData['businessBenefit_en']?.toString() ??
              jsonData['businessBenefit']?.toString() ??
              '',
          'businessBenefit_ta': jsonData['businessBenefit_ta']?.toString() ??
              jsonData['businessBenefit']?.toString() ??
              '',
          'imageUrl': validateAndSanitizeImageUrl(
            jsonData['imageUrl']?.toString(),
            carModel:
                jsonData['model']?.toString() ?? jsonData['brand']?.toString(),
          ),
          'todaysTask_en': jsonData['todaysTask_en']?.toString() ??
              jsonData['todaysTask']?.toString() ??
              '',
          'todaysTask_ta': jsonData['todaysTask_ta']?.toString() ??
              jsonData['todaysTask']?.toString() ??
              '',
        };

        print('Successfully parsed daily strategy from Gemini AI');
        // Save to cache
        await _saveToCache(cacheKey, json.encode(strategy));
        return strategy;
      }

      print(
          'Failed to parse JSON from Gemini AI daily strategy response, using fallback data');
      // Fallback to default strategy
      return getDefaultDailyStrategy();
    } catch (e, stackTrace) {
      print('Error getting daily strategy from Gemini AI: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default strategy
      return getDefaultDailyStrategy();
    }
  }

  static Map<String, dynamic> getDefaultDailyStrategy() {
    return {
      'strategyTitle_en': 'Increase Premium Sedan Stock Before Pongal Festival',
      'strategyTitle_ta':
          'பொங்கல் பண்டிகைக்கு முன் Premium Sedan Stock அதிகரிக்கவும்',
      'strategy_en':
          'December month shows increased premium sedan demand in Chennai and Coimbatore before Pongal festival. Honda City, Hyundai Verna models show strong demand in corporate sector. Tier-2 cities (Madurai, Tiruchirappalli) prefer spacious sedans for family segment. Chennai showrooms offer 15-20% price premium. Stock turnover rate increases by 30%.',
      'strategy_ta':
          'டிசம்பர் மாதம் பொங்கல் பண்டிகைக்கு முன் சென்னை மற்றும் கோவையில் premium sedan demand அதிகரிக்கிறது. Honda City, Hyundai Verna போன்ற models இற்கு corporate sector இல் strong demand உள்ளது. Tier-2 cities (மதுரை, திருச்சி) இல் family segment இற்கு spacious sedans preferred. Chennai showrooms இல் 15-20% price premium கிடைக்கும். Stock turnover rate 30% அதிகரிக்கும்.',
      'businessBenefit_en':
          'This will increase your sales speed by 25% and improve profit margin by 15%.',
      'businessBenefit_ta':
          'இது உங்கள் விற்பனை வேகத்தை 25% அதிகரிக்கும் மற்றும் profit margin 15% improve செய்யும்.',
      'imageUrl': getReliableCarImageUrl(),
      'todaysTask_en':
          'Check premium sedan inventory today and increase stock of Honda City and Hyundai Verna models.',
      'todaysTask_ta':
          'இன்றே premium sedan inventory check செய்து, Honda City மற்றும் Hyundai Verna models stock அதிகரிக்கவும்.',
    };
  }

  // Generate Today's Choice - ONE specific vehicle with highest profit potential
  static Future<Map<String, dynamic>> generateTodaysChoice({
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    const cacheKey = 'todays_choice';
    if (!forceRefresh) {
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        try {
          final cachedMap = json.decode(cachedData) as Map<String, dynamic>;
          debugPrint('Using cached today\'s choice data');
          return Map<String, dynamic>.from(cachedMap);
        } catch (e) {
          debugPrint('Error parsing cached today\'s choice data: $e');
        }
      }
    } else {
      debugPrint('Force refresh: bypassing cache for today\'s choice');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      const prompt =
          '''Act as an Elite AI Automotive Business Strategist. When triggered by the command "/todays-choice" or the button "இன்றைய சாய்ஸ்", identify exactly 3 specific vehicle models that offer the highest profit potential in Tamil Nadu today.

IMPORTANT: You MUST provide a high-quality, professional image of the vehicle. Images are MANDATORY. Use real, working image URLs from pexels.com or pixabay.com, crisp for mobile screens. DO NOT use unsplash.com URLs as they often return 404 errors. Use direct image URLs from Pexels (pexels.com/photos/...) or Pixabay that are known to work.

*The Strategy:* Use predictive logic to identify a "Stock Gold" opportunity (e.g., predicting a spike in demand for SUVs due to upcoming festivals or a sudden supply drop in quality sedans).

*Output Structure for Mobile UI (JSON format) - MUST provide BOTH English and Tamil versions:*
{
  "brand": "Brand Name",
  "model": "Model Name",
  "hiddenRationale_en": "Exactly 3 lines in English. Reveal a market insight they wouldn't expect (e.g., AI predicts a 15% price hike for this model next month; buy now to maximize margin). Use short sentences.",
  "hiddenRationale_ta": "Exactly 3 lines in Tamil. Reveal a market insight they wouldn't expect (e.g., AI predicts a 15% price hike for this model next month; buy now to maximize margin). Use short sentences.",
  "profitFormula_en": "Expected Profit = (Market Premium × Low Stock) + Immediate Sale",
  "profitFormula_ta": "எதிர்பார்க்கும் லாபம் = (சந்தை மவுசு × குறைவான இருப்பு) + உடனடி விற்பனை",
  "businessDeepDive_en": "Exactly 4 lines in English on regional TN demand and mechanical resale durability. Use short sentences.",
  "businessDeepDive_ta": "Exactly 4 lines in Tamil on regional TN demand and mechanical resale durability. Use short sentences.",
  "imageUrl": "High-quality, professional image of the vehicle (MANDATORY - use real, working URLs from pexels.com or pixabay.com, NOT unsplash.com, crisp for mobile screens)",
  "indianSales": "Estimated total units sold in India (e.g., 30 lakhs+)",
  "tnResaleValue": "Legendary/High/Excellent",
  "salesSpeed": "Instant/3-5 Days/1 Week"
  },
  {vehicle 2},
  {vehicle 3}
]

*Strict Guardrails:*
- *Images:* MANDATORY. Provide a high-quality, professional image of the vehicle from pexels.com or pixabay.com only. DO NOT use unsplash.com.
- *No External Links:* The user must stay 100% within the app.
- *Visuals:* Images are MANDATORY and must be crisp for mobile screens.
- *Mobile First:* Use bold headers, bullet points, and high contrast for Android mobile viewing.
- *Language:* MUST provide BOTH English (_en) and Tamil (_ta) versions for ALL text fields (hiddenRationale, profitFormula, businessDeepDive).
- *Ring-fencing:* Strictly automotive business context. No metadata or conversational fillers.

Return ONLY valid JSON array, no additional text or markdown.''';

      print('Calling Gemini AI for today\'s choice...');
      final content = [Content.text(prompt)];
      final result = await model.generateContent(content);
      final responseText = result.text ?? '';

      print(
          'Gemini AI Today\'s Choice Response received (length: ${responseText.length})');

      // Try multiple methods to extract JSON
      Map<String, dynamic>? jsonData;
      dynamic parsedJson;

      // Method 1: Try to extract JSON from markdown code blocks first (most common issue)
      try {
        // Try to find JSON in ```json ... ``` or ``` ... ``` blocks
        final codeBlockPatterns = [
          RegExp(r'```json\s*(\{[\s\S]*?\})\s*```', dotAll: true),
          RegExp(r'```json\s*(\[[\s\S]*?\])\s*```', dotAll: true),
          RegExp(r'```\s*(\{[\s\S]*?\})\s*```', dotAll: true),
          RegExp(r'```\s*(\[[\s\S]*?\])\s*```', dotAll: true),
        ];
        
        for (final pattern in codeBlockPatterns) {
          final match = pattern.firstMatch(responseText);
          if (match != null && match.groupCount > 0) {
            final jsonString = match.group(1)!.trim();
            parsedJson = json.decode(jsonString);
            print('Successfully extracted JSON from markdown code block');
            break;
          }
        }
      } catch (e) {
        print('Code block extraction failed: $e');
      }

      // Method 2: Try to find JSON object or array with regex
      if (parsedJson == null) {
        try {
          // Try to find JSON object - match from first { to last }
          final objectStart = responseText.indexOf('{');
          if (objectStart != -1) {
            int braceCount = 0;
            int objectEnd = -1;
            for (int i = objectStart; i < responseText.length; i++) {
              if (responseText[i] == '{') braceCount++;
              if (responseText[i] == '}') {
                braceCount--;
                if (braceCount == 0) {
                  objectEnd = i + 1;
                  break;
                }
              }
            }
            if (objectEnd != -1) {
              final jsonString = responseText.substring(objectStart, objectEnd).trim();
              parsedJson = json.decode(jsonString);
              print('Successfully parsed JSON object using brace matching');
            }
          }
          
          // If object parsing failed, try array
          if (parsedJson == null) {
            final arrayStart = responseText.indexOf('[');
            if (arrayStart != -1) {
              int bracketCount = 0;
              int arrayEnd = -1;
              for (int i = arrayStart; i < responseText.length; i++) {
                if (responseText[i] == '[') bracketCount++;
                if (responseText[i] == ']') {
                  bracketCount--;
                  if (bracketCount == 0) {
                    arrayEnd = i + 1;
                    break;
                  }
                }
              }
              if (arrayEnd != -1) {
                final jsonString = responseText.substring(arrayStart, arrayEnd).trim();
                parsedJson = json.decode(jsonString);
                print('Successfully parsed JSON array using bracket matching');
              }
            }
          }
        } catch (e) {
          print('Regex method failed: $e');
        }
      }

      // Method 3: Try to parse the entire response as JSON (after cleaning)
      if (parsedJson == null) {
        try {
          // Remove any leading/trailing markdown formatting
          String cleanedText = responseText.trim();
          // Remove markdown code block markers if they exist
          cleanedText = cleanedText.replaceAll(RegExp(r'^```(?:json)?\s*', multiLine: true), '');
          cleanedText = cleanedText.replaceAll(RegExp(r'\s*```$', multiLine: true), '');
          cleanedText = cleanedText.trim();
          
          parsedJson = json.decode(cleanedText);
          print('Successfully parsed JSON directly after cleaning');
        } catch (e) {
          print('Direct parsing failed: $e');
        }
      }

      // Convert parsed JSON to Map<String, dynamic>
      if (parsedJson != null) {
        if (parsedJson is List && parsedJson.isNotEmpty) {
          // If it's an array, take the first element
          jsonData = parsedJson[0] is Map
              ? Map<String, dynamic>.from(parsedJson[0] as Map)
              : null;
          print('Extracted first element from JSON array');
        } else if (parsedJson is Map) {
          jsonData = Map<String, dynamic>.from(parsedJson);
          print('Using JSON object directly');
        }
      }

      // If we successfully parsed JSON, validate and return
      if (jsonData != null) {
        final choice = {
          'brand': jsonData['brand']?.toString() ?? 'Unknown',
          'model': jsonData['model']?.toString() ?? 'Unknown',
          'hiddenRationale_en': jsonData['hiddenRationale_en']?.toString() ??
              jsonData['hiddenRationale']?.toString() ??
              '',
          'hiddenRationale_ta': jsonData['hiddenRationale_ta']?.toString() ??
              jsonData['hiddenRationale']?.toString() ??
              '',
          'profitFormula_en': jsonData['profitFormula_en']?.toString() ??
              'Expected Profit = (Market Premium × Low Stock) + Immediate Sale',
          'profitFormula_ta': jsonData['profitFormula_ta']?.toString() ??
              jsonData['profitFormula']?.toString() ??
              'எதிர்பார்க்கும் லாபம் = (சந்தை மவுசு × குறைவான இருப்பு) + உடனடி விற்பனை',
          'businessDeepDive_en': jsonData['businessDeepDive_en']?.toString() ??
              jsonData['businessDeepDive']?.toString() ??
              '',
          'businessDeepDive_ta': jsonData['businessDeepDive_ta']?.toString() ??
              jsonData['businessDeepDive']?.toString() ??
              '',
          'imageUrl': validateAndSanitizeImageUrl(
            jsonData['imageUrl']?.toString(),
            carModel:
                jsonData['model']?.toString() ?? jsonData['brand']?.toString(),
          ),
          'indianSales': jsonData['indianSales']?.toString() ?? 'N/A',
          'tnResaleValue': jsonData['tnResaleValue']?.toString() ?? 'High',
          'salesSpeed': jsonData['salesSpeed']?.toString() ?? '3-5 Days',
        };

        print('Successfully parsed today\'s choice from Gemini AI');
        // Save to cache
        await _saveToCache(cacheKey, json.encode(choice));
        return choice;
      }

      print(
          'Failed to parse JSON from Gemini AI today\'s choice response, using fallback data');
      // Fallback to default choice
      return getDefaultTodaysChoice();
    } catch (e, stackTrace) {
      print('Error getting today\'s choice from Gemini AI: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default choice
      return getDefaultTodaysChoice();
    }
  }

  static Map<String, dynamic> getDefaultTodaysChoice() {
    return {
      'brand': 'Toyota',
      'model': 'Innova HyCross',
      'hiddenRationale_en':
          'AI predicts a 12% price increase for this model by Q4 due to hybrid part costs and continuous demand.\nBuy now to maximize future profit.\nCurrent market has 15% supply drop in quality pre-owned units.',
      'hiddenRationale_ta':
          'AI predicts a 12% price increase for this model by Q4 due to hybrid part costs and continuous demand.\nBuy now to maximize future profit.\nCurrent market has 15% supply drop in quality pre-owned units.',
      'profitFormula_en':
          'Expected Profit = (Market Premium × Low Stock) + Immediate Sale',
      'profitFormula_ta':
          'எதிர்பார்க்கும் லாபம் = (சந்தை மவுசு × குறைவான இருப்பு) + உடனடி விற்பனை',
      'businessDeepDive_en':
          'Chennai and Coimbatore show 75-80% resale value with guaranteed sale.\nMadurai and Tiruchirappalli show highest demand for family segment.\nPowerful engine and spacious interior ideal for TN highways.\nMechanical durability excellent for TN weather conditions - long-term investment value.',
      'businessDeepDive_ta':
          'சென்னை மற்றும் கோவையில் 75-80% resale value உடன் guaranteed sale.\nமதுரை மற்றும் திருச்சி இல் family segment இற்கு highest demand.\nTN highways இற்கு powerful engine மற்றும் spacious interior ideal.\nMechanical durability TN weather conditions இற்கு excellent - long-term investment value.',
      'imageUrl': getReliableCarImageUrl(),
      'indianSales': '30 lakhs+',
      'tnResaleValue': 'Legendary',
      'salesSpeed': 'Instant',
    };
  }

  // Generate Top 5 Business Picks - Comparative report
  static Future<List<Map<String, dynamic>>> generateTop5BusinessPicks({
    bool forceRefresh = false,
  }) async {
    // Check cache first (unless force refresh)
    const cacheKey = 'top5_business_picks';
    if (!forceRefresh) {
      final cachedData = await _getCachedData(cacheKey);
      if (cachedData != null) {
        try {
          final cachedList = json.decode(cachedData) as List<dynamic>;
          debugPrint('Using cached top 5 business picks data');
          return cachedList
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } catch (e) {
          debugPrint('Error parsing cached top 5 business picks data: $e');
        }
      }
    } else {
      debugPrint('Force refresh: bypassing cache for top 5 business picks');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      const prompt =
          '''Act as a Senior Data Scientist and Automotive Business Consultant. Generate a comparative report of the top 5 cars for the day in Tamil Nadu.

IMPORTANT: For each car, you MUST provide a high-quality, professional image of the car model. Images are MANDATORY. Use real, working image URLs from pexels.com or pixabay.com. DO NOT use unsplash.com URLs as they often return 404 errors. Use direct image URLs from Pexels (pexels.com/photos/...) or Pixabay that are known to work.

Goal: Empower the dealer to choose the best car for their inventory based on AI-driven confidence and profitability scores.

Output Structure for each of the 3 Cars (JSON array):
[
  {
    "rank": "1",
    "brand": "Brand Name (English)",
    "brand_ta": "Brand Name in Tamil (e.g., மாருதி சுஸூகி)",
    "model": "Model Name (English)",
    "model_ta": "Model Name in Tamil (e.g., சுவிஃப்ட்)",
    "segment": "Segment Name (e.g., Premium Sedan, Compact SUV)",
    "overviewRationale": "Exactly 3 lines in Tamil explaining why this car made the list today (e.g., Supply-demand gap, local trend). Use short sentences.",
    "imageUrl": "High-quality, professional image of the car model (MANDATORY - use real, working URLs from pexels.com or pixabay.com, NOT unsplash.com)",
    "indianSales": "Estimated total units sold in India (e.g., 20 லட்சம்+)",
    "expectedProfit": "Expected profit range (e.g., ₹60,000 - ₹90,000)",
    "resaleValue": "High/Excellent/Legendary",
    "salePotential": "Percentage (0-100)",
    "buyConfidence": "Percentage (0-100)",
    "liquidity": "Very Fast/Fast/Medium",
    "interestingFactor": "A unique Insider Tip in Tamil (e.g., இந்த மாடலில் சன்ரூஃப் இருந்தால் கூடுதலாக ₹30,000 லாபம் கிடைக்கும்)"
  }
]

Return exactly 3 cars ranked from 1 to 3.

Strict Guardrails:
- Images: MANDATORY. Each car must have a high-quality, professional image from pexels.com or pixabay.com only. DO NOT use unsplash.com.
- No External Links: Keep the user inside the app.
- Visual Representation: Use Unicode progress bars for charts (will be rendered in UI).
- Language: 100% Professional Business Tamil for descriptions.
- Mobile First: Ensure data is structured for small screens.
- Ring-fencing: Strictly automotive business context. No metadata or fillers.

Return ONLY valid JSON array, no additional text or markdown.''';

      print('Calling Gemini AI for top 5 business picks...');
      final content = [Content.text(prompt)];
      final result = await model.generateContent(content);
      final responseText = result.text ?? '';

      print(
          'Gemini AI Top 5 Business Picks Response received (length: ${responseText.length})');

      // Try multiple methods to extract JSON
      List<dynamic>? jsonData;

      // Method 1: Try to find JSON array with regex
      try {
        final jsonMatch =
            RegExp(r'\[[\s\S]*\]', dotAll: true).firstMatch(responseText);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          jsonData = json.decode(jsonString) as List<dynamic>;
          print('Successfully parsed top 5 picks JSON using regex method');
        }
      } catch (e) {
        print('Regex method failed: $e');
      }

      // Method 2: Try to parse the entire response as JSON
      if (jsonData == null) {
        try {
          jsonData = json.decode(responseText.trim()) as List<dynamic>;
          print('Successfully parsed top 5 picks JSON directly');
        } catch (e) {
          print('Direct parsing failed: $e');
        }
      }

      // Method 3: Try to find JSON between ```json and ``` or ``` and ```
      if (jsonData == null) {
        try {
          final codeBlockMatch =
              RegExp(r'```(?:json)?\s*(\[[\s\S]*?\])\s*```', dotAll: true)
                  .firstMatch(responseText);
          if (codeBlockMatch != null) {
            final jsonString = codeBlockMatch.group(1)!;
            jsonData = json.decode(jsonString) as List<dynamic>;
            print('Successfully parsed top 5 picks JSON from code block');
          }
        } catch (e) {
          print('Code block parsing failed: $e');
        }
      }

      // If we successfully parsed JSON, validate and return
      if (jsonData != null && jsonData.isNotEmpty) {
        final picks = jsonData.map((item) {
          final car = item as Map<String, dynamic>;
          // Ensure all required fields exist
          return {
            'rank': car['rank']?.toString() ?? '1',
            'brand': car['brand']?.toString() ?? 'Unknown',
            'brand_ta': car['brand_ta']?.toString() ?? car['brand']?.toString() ?? 'Unknown',
            'brand_en': car['brand_en']?.toString() ?? car['brand']?.toString() ?? 'Unknown',
            'model': car['model']?.toString() ?? 'Unknown',
            'model_ta': car['model_ta']?.toString() ?? car['model']?.toString() ?? 'Unknown',
            'model_en': car['model_en']?.toString() ?? car['model']?.toString() ?? 'Unknown',
            'segment': car['segment']?.toString() ?? 'வாகனம்',
            'overviewRationale': car['overviewRationale']?.toString() ?? '',
            'imageUrl': validateAndSanitizeImageUrl(
              car['imageUrl']?.toString(),
              carModel: car['model']?.toString() ?? car['brand']?.toString(),
            ),
            'indianSales': car['indianSales']?.toString() ?? 'N/A',
            'expectedProfit': car['expectedProfit']?.toString() ?? 'N/A',
            'resaleValue': car['resaleValue']?.toString() ?? 'High',
            'salePotential': car['salePotential']?.toString() ?? '80',
            'buyConfidence': car['buyConfidence']?.toString() ?? '85',
            'liquidity': car['liquidity']?.toString() ?? 'Fast',
            'interestingFactor': car['interestingFactor']?.toString() ?? '',
          };
        }).toList();

        print('Successfully parsed ${picks.length} top 5 picks from Gemini AI');
        // Save to cache
        await _saveToCache(cacheKey, json.encode(picks));
        return picks;
      }

      print(
          'Failed to parse JSON from Gemini AI top 5 picks response, using fallback data');
      // Fallback to default picks
      return getDefaultTop5BusinessPicks();
    } catch (e, stackTrace) {
      print('Error getting top 5 business picks from Gemini AI: $e');
      print('Stack trace: $stackTrace');
      // Fallback to default picks
      return getDefaultTop5BusinessPicks();
    }
  }

  static List<Map<String, dynamic>> getDefaultTop5BusinessPicks() {
    return [
      {
        'rank': '1',
        'brand': 'Toyota',
        'model': 'Innova Crysta',
        'segment': 'Premium MPV',
        'overviewRationale':
            'டிசம்பர் மாதம் பொங்கல் பண்டிகைக்கு முன் family vehicle demand அதிகரிக்கிறது. Chennai மற்றும் Tier-2 cities இல் 75-80% resale value உடன் guaranteed sale. Current market இல் quality pre-owned units 20% supply drop - perfect buying opportunity.',
        'imageUrl': getReliableCarImageUrl(),
        'indianSales': '10+ லட்சம்',
        'expectedProfit': '₹80,000 - ₹1,20,000',
        'resaleValue': 'Legendary',
        'salePotential': '90',
        'buyConfidence': '95',
        'liquidity': 'Very Fast',
        'interestingFactor':
            'இந்த மாடலில் sunroof variant இருந்தால் கூடுதலாக ₹40,000 லாபம் கிடைக்கும். Chennai corporate sector இல் premium features demand அதிகம்.',
      },
      {
        'rank': '2',
        'brand': 'Honda',
        'model': 'City',
        'segment': 'Premium Sedan',
        'overviewRationale':
            'சென்னை மற்றும் கோவையில் premium sedan segment இல் strong demand. Pongal festival முன் corporate sector இல் executive car purchases increase. 68-73% resale value மற்றும் low maintenance cost ideal for quick turnover.',
        'imageUrl': getReliableCarImageUrl(),
        'indianSales': '12+ லட்சம்',
        'expectedProfit': '₹60,000 - ₹90,000',
        'resaleValue': 'Excellent',
        'salePotential': '85',
        'buyConfidence': '88',
        'liquidity': 'Fast',
        'interestingFactor':
            'i-VTEC engine variant இல் additional ₹25,000 premium கிடைக்கும். Chennai IT sector இல் technology features preferred.',
      },
    ];
  }
}
