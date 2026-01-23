import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/car_provider.dart';
import 'providers/popular_cars_provider.dart';
import 'providers/trends_provider.dart';
import 'providers/car_launches_provider.dart';
import 'providers/profitable_cars_provider.dart';
import 'providers/tn_market_kings_provider.dart';
import 'providers/daily_strategy_provider.dart';
import 'providers/todays_choice_provider.dart';
import 'providers/top5_picks_provider.dart';
import 'providers/ai_usage_provider.dart';
import 'services/ai_service.dart';
import 'utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  // For Flutter web, we need to load from assets
  bool envLoaded = false;

  // Try multiple methods to load .env file
  // Method 1: Try loading from root (for native platforms)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✓ Successfully loaded .env file from root');
    envLoaded = true;
  } catch (e) {
    debugPrint('✗ Could not load .env from root: $e');
  }

  // Method 2: Try loading from assets (for web)
  if (!envLoaded) {
    try {
      await dotenv.load(fileName: "assets/.env");
      debugPrint('✓ Successfully loaded .env file from assets');
      envLoaded = true;
    } catch (e) {
      debugPrint('✗ Could not load .env from assets: $e');
    }
  }

  // Method 3: Try loading without path (default behavior)
  if (!envLoaded) {
    try {
      await dotenv.load();
      debugPrint('✓ Successfully loaded .env file (default)');
      envLoaded = true;
    } catch (e) {
      debugPrint('✗ Could not load .env (default): $e');
    }
  }

  // Method 4: Manual load from assets as fallback for web
  if (!envLoaded) {
    try {
      final String envString = await rootBundle.loadString('assets/.env');
      // Handle both Unix (LF) and Windows (CRLF) line endings
      final lines = envString.replaceAll('\r\n', '\n').split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.isNotEmpty && !line.startsWith('#')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = parts[1].trim();
            dotenv.env[key] = value;
            debugPrint('✓ Loaded env key: $key');
          }
        }
      }
      debugPrint('✓ Successfully loaded .env file manually from assets');
      envLoaded = true;
    } catch (e) {
      debugPrint('✗ Could not load .env manually from assets: $e');
    }
  }

  // Verify API key was loaded and set it in AIService
  String? loadedApiKey;
  if (envLoaded) {
    loadedApiKey = dotenv.env['GEMINI_API_KEY'];
    if (loadedApiKey != null && loadedApiKey.isNotEmpty) {
      debugPrint(
          '✓ API Key loaded successfully: ${loadedApiKey.substring(0, 10)}...');
      debugPrint('✓ API Key length: ${loadedApiKey.length}');
      debugPrint('✓ dotenv.isInitialized: ${dotenv.isInitialized}');
      // Set the API key in AIService for direct access
      AIService.setApiKey(loadedApiKey);
    } else {
      debugPrint(
          '✗ WARNING: GEMINI_API_KEY is empty or not found in .env file');
      debugPrint('Available env keys: ${dotenv.env.keys.toList()}');
    }
  } else {
    debugPrint('✗ ERROR: Could not load .env file from root or assets');
    debugPrint(
        'Please ensure .env file exists with: GEMINI_API_KEY=your_api_key');
  }

  // Final check: if we still don't have an API key, try to get it from manual parsing
  if (loadedApiKey == null || loadedApiKey.isEmpty) {
    try {
      // Try loading from assets/.env with explicit UTF-8 encoding
      final ByteData data = await rootBundle.load('assets/.env');
      final String envString = utf8.decode(data.buffer.asUint8List());
      final lines = envString.replaceAll('\r\n', '\n').split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.isNotEmpty && !line.startsWith('#')) {
          final parts = line.split('=');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = parts[1].trim();
            if (key == 'GEMINI_API_KEY' && value.isNotEmpty) {
              loadedApiKey = value;
              AIService.setApiKey(value);
              debugPrint('✓ API Key loaded manually from assets/.env (UTF-8)');
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('✗ Could not load API key manually: $e');
      // Last resort: hardcode the API key (only for development)
      debugPrint('⚠️  Attempting to use API key directly...');
      const fallbackKey = 'AIzaSyD1vbAbHeif4W7006H0etfJbUyEFAtKAm8';
      if (fallbackKey.isNotEmpty) {
        loadedApiKey = fallbackKey;
        AIService.setApiKey(fallbackKey);
        debugPrint('✓ API Key set directly (fallback)');
      }
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AIUsageProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => PopularCarsProvider()),
        ChangeNotifierProvider(create: (_) => TrendsProvider()),
        ChangeNotifierProvider(create: (_) => CarLaunchesProvider()),
        ChangeNotifierProvider(create: (_) => ProfitableCarsProvider()),
        ChangeNotifierProvider(create: (_) => TNMarketKingsProvider()),
        ChangeNotifierProvider(create: (_) => DailyStrategyProvider()),
        ChangeNotifierProvider(create: (_) => TodaysChoiceProvider()),
        ChangeNotifierProvider(create: (_) => Top5PicksProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp.router(
            title: 'Aathiksh AutoMart',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF1E3A8A),
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Roboto',
              useMaterial3: true,
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('ta', ''),
            ],
            locale: languageProvider.currentLocale,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
