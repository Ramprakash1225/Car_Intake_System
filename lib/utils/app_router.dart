import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/analyze_car_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/car_details_screen.dart';
import '../screens/popular_cars_screen.dart';
import '../screens/popular_car_details_screen.dart';
import '../screens/trends_screen.dart';
import '../screens/car_launches_screen.dart';
import '../screens/profitable_cars_screen.dart';
import '../screens/tn_market_kings_screen.dart';
import '../screens/daily_strategy_screen.dart';
import '../screens/todays_choice_screen.dart';
import '../screens/top5_picks_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoginPage = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginPage) {
        return '/login';
      }
      if (isLoggedIn && isLoginPage) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/analyze',
        builder: (context, state) => const AnalyzeCarScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/car/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CarDetailsScreen(carId: int.parse(id));
        },
      ),
      GoRoute(
        path: '/popular-cars',
        builder: (context, state) => const PopularCarsScreen(),
      ),
      GoRoute(
        path: '/popular-car/:index',
        builder: (context, state) {
          final index = state.pathParameters['index']!;
          return PopularCarDetailsScreen(carIndex: int.parse(index));
        },
      ),
      GoRoute(
        path: '/trends',
        builder: (context, state) => const TrendsScreen(),
      ),
      GoRoute(
        path: '/car-launches',
        builder: (context, state) => const CarLaunchesScreen(),
      ),
      GoRoute(
        path: '/profitable-cars',
        builder: (context, state) => const ProfitableCarsScreen(),
      ),
      GoRoute(
        path: '/tn-market-kings',
        builder: (context, state) => const TNMarketKingsScreen(),
      ),
      GoRoute(
        path: '/daily-strategy',
        builder: (context, state) => const DailyStrategyScreen(),
      ),
      GoRoute(
        path: '/todays-choice',
        builder: (context, state) => const TodaysChoiceScreen(),
      ),
      GoRoute(
        path: '/top-5-picks',
        builder: (context, state) => const Top5PicksScreen(),
      ),
    ],
  );
}

