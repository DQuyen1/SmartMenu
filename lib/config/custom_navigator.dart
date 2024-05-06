import 'package:flutter/material.dart';

class CustomNavigator {
  void navigateTo(context, routeName) {
    Navigator.pushNamed(context, routeName);
  }

  void navigateBack(context, routerName) {
    Navigator.pop(context, routerName);
  }
}
