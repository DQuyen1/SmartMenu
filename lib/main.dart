import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_menu/config/app_router.dart';
import 'package:smart_menu/presentation/screens/shared/login_screen.dart';
import 'package:smart_menu/presentation/widgets/custom_navigation.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: AppRouter.getRoutes(),
      // initialRoute: AppRouter.splash,
      home: LoginScreen(),
    );
  }
}
