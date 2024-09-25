import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_menu/presentation/screens/partner/dashboard.dart';
import 'package:smart_menu/presentation/screens/shared/profile.dart';

class NavigatorProvider extends StatefulWidget {
  const NavigatorProvider({super.key});

  @override
  State<NavigatorProvider> createState() => NavigatorProviderState();
}

class NavigatorProviderState extends State<NavigatorProvider> {
  // Initial page index
  int currentPageIndex = 0;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? userId;
  String? token;
  String? brandId;
  String? roleId;
  String? storeId;

  @override
  void initState() {
    super.initState();
    _loadStorageValues();
  }

  Future<void> _loadStorageValues() async {
    userId = await _storage.read(key: 'userId');
    token = await _storage.read(key: 'token');
    brandId = await _storage.read(key: 'brandId');
    roleId = await _storage.read(key: 'roleId');
    storeId = await _storage.read(key: 'storeId');

    // Update the state to reflect the new values
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                  icon: Badge(
                    // label: Text('2'),
                    child: Icon(Icons.account_circle),
                  ),
                  label: 'Profile',
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: currentPageIndex,
        children: <Widget>[
          DashBoardScreen(
            userId: userId ?? '',
            token: token ?? '',
            brandId: int.tryParse(brandId ?? '0') ?? 0,
            storeId: int.tryParse(storeId ?? '0') ?? 0,
          ),
        ],
      ),
    );
  }
}
