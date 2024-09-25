import 'package:flutter/material.dart';
import 'package:smart_menu/presentation/screens/partner/dashboard.dart';
import 'package:smart_menu/presentation/screens/shared/login_screen.dart';
import 'package:smart_menu/presentation/screens/splash.dart';
import 'package:smart_menu/presentation/widgets/custom_navigation.dart';

class AppRouter {
  static const String splash = '/splash';
  //static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // login: (context) => LoginScreen(),
      splash: (context) => SplashScreen(),
      home: (context) => LoginScreen(),
    };
  }
}
