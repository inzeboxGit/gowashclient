import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/sign_up_screen.dart';
import '../../features/booking/data/models/booking_route_arguments.dart';
import '../../features/booking/presentation/pages/order_summary_screen.dart';
import '../../features/booking/presentation/pages/orders_screen.dart';
import '../../features/booking/presentation/pages/washer_details_screen.dart';
import '../../features/home/presentation/pages/main_search_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Map<String, WidgetBuilder> get routes {
    return <String, WidgetBuilder>{
      AppRoutes.signUp: (context) => const SignUpScreen(),
      AppRoutes.login: (context) => const LoginScreen(),
      AppRoutes.mainSearch: (context) => const MainSearchScreen(),
      AppRoutes.profile: (context) => const ProfileScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.washerDetails:
        final Object? arguments = settings.arguments;
        if (arguments is WasherDetailsRouteArguments) {
          return MaterialPageRoute<void>(
            builder: (context) => WasherDetailsScreen(
              washerId: arguments.washerId,
              preview: arguments.preview,
            ),
            settings: settings,
          );
        }
        return _errorRoute(settings, 'Washer details arguments were missing.');
      case AppRoutes.orderSummary:
        final Object? arguments = settings.arguments;
        if (arguments is OrderSummaryRouteArguments) {
          return MaterialPageRoute<void>(
            builder: (context) => OrderSummaryScreen(draft: arguments.draft),
            settings: settings,
          );
        }
        return _errorRoute(settings, 'Order summary arguments were missing.');
      case AppRoutes.orders:
        final Object? arguments = settings.arguments;
        if (arguments is OrdersRouteArguments) {
          return MaterialPageRoute<void>(
            builder: (context) => OrdersScreen(
              showCompletedFirst: arguments.showCompletedFirst,
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(
          builder: (context) => const OrdersScreen(),
          settings: settings,
        );
    }
    return null;
  }

  static Route<void> _errorRoute(RouteSettings settings, String message) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
