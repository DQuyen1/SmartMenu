import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/config/app_router.dart';
import 'package:smart_menu/config/custom_navigator.dart';
import 'package:smart_menu/presentation/screens/display_image.dart';
import 'package:smart_menu/presentation/screens/display_image.dart';
import 'package:smart_menu/presentation/screens/partner/display_device_form.dart';
import 'package:smart_menu/presentation/screens/partner/display_image_form.dart';
import 'package:smart_menu/presentation/screens/shared/login_screen.dart';
import 'package:smart_menu/presentation/widgets/custom_navigation.dart';

void main() {
  HttpOverrides.global = _DevHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      routes: AppRouter.getRoutes(),
      initialRoute: AppRouter.home,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
