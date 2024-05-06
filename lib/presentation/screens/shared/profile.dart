import 'package:flutter/material.dart';
import 'package:smart_menu/config/constants.dart';
import 'package:smart_menu/presentation/widgets/profile_content.dart';
import 'package:smart_menu/presentation/widgets/user_image.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const content = [
      'Password',
      'Notifications',
      'Settings',
      'Support',
      'Signout'
    ];

    ProfileContent chooseContentAndIcon(String name) {
      switch (name) {
        case 'Password':
          return const ProfileContent(
              name: 'Password', icon: Icons.lock_open_outlined);
        case 'Settings':
          return const ProfileContent(
              name: 'Settings', icon: Icons.settings_outlined);
        case 'Support':
          return const ProfileContent(
              name: 'Support', icon: Icons.help_outline_outlined);
        case 'Signout':
          return const ProfileContent(name: 'Signout', icon: Icons.logout);
        case 'Notifications':
          return const ProfileContent(
              name: 'Notifications', icon: Icons.notifications_outlined);
        default:
          return const ProfileContent(
            name: 'unknown',
            icon: Icons.question_mark,
          ); // Handle default case (optional)
      }
    }

    List<Widget> renderContent() {
      return content.map((e) => chooseContentAndIcon(e)).toList();
    }

    return Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              decoration: const BoxDecoration(
                color: AppBackGroundColor.profileHeaderBackground,
                // color: Color(0xFF0096FF),
                // color: Color.fromARGB(255, 105, 200, 245),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    title: const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(95, 134, 240, 240),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    // backgroundColor: Colors.yellow,
                  ),
                  const UserContent(),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ...renderContent()
          ],
        ));
  }
}
