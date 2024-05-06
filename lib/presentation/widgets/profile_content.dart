import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:smart_menu/config/constants.dart';

class ProfileContent extends StatefulWidget {
  final String name;
  final IconData icon;

  const ProfileContent({super.key, required this.name, required this.icon});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
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
