import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_menu/config/app_router.dart';
import 'package:smart_menu/config/constants.dart';
import 'package:smart_menu/config/custom_navigator.dart';

class ProfileContent extends StatefulWidget {
  final String name;
  final IconData icon;

  const ProfileContent({super.key, required this.name, required this.icon});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  static const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final CustomNavigator navigator = CustomNavigator();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.name == 'Signout') {
          navigator.navigateTo(context, AppRouter.home);
          secureStorage.deleteAll();
        }

        log('Pressed');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 30),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          height: 60,
          width: 360,
          color: AppColor.backgroundColor,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Icon(
                        widget.icon,
                        color: AppColor.iconColor,
                      ),
                    ),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  AppIcon.chevronRight,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
