import 'package:flutter/material.dart';
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
import 'utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found - will use fallback values
    debugPrint('Warning: .env file not found. Using default API key configuration.');
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

