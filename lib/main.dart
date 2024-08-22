import 'dart:io';
import 'package:flutter/material.dart';
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
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
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
