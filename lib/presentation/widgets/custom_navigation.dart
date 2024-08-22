import 'package:flutter/material.dart';
import 'package:smart_menu/presentation/screens/partner/dashboard.dart';
import 'package:smart_menu/presentation/screens/shared/login_screen.dart';
import 'package:smart_menu/presentation/screens/shared/profile.dart';

class NavigatorProvider extends StatefulWidget {
  const NavigatorProvider({super.key});

  @override
  State<NavigatorProvider> createState() => NavigatorProviderState();
}

class NavigatorProviderState extends State<NavigatorProvider> {
  // Initial page index set to display NavigatorProvider on first launch
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // final ThemeData theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: currentPageIndex != 1
          ? NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              indicatorColor: const Color.fromARGB(255, 202, 202, 201),
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Badge(child: Icon(Icons.notifications_sharp)),
                  label: 'Notifications',
                ),
                NavigationDestination(
                  icon: Badge(
                    label: Text('2'),
                    child: Icon(Icons.account_circle),
                  ),
                  label: 'Profile',
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: currentPageIndex,
        children: const <Widget>[
          DashboardScreen(
            userId: '',
            brandId: 0,
            storeId: 0,
          ),
          ProfileScreen(),
        ],
      ),
    );
  }
}
