import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_menu/presentation/screens/partner/dashboard.dart';
import 'package:smart_menu/presentation/screens/shared/login_screen.dart';
import 'package:smart_menu/presentation/screens/shared/profile.dart';

class NavBar extends StatelessWidget {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(''),
            accountEmail: Text(''),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
            ),
          ),
          ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () async {
                String? token = await _storage.read(key: 'token');
                String? brandIdStr = await _storage.read(key: 'brandId');
                String? storeIdStr = await _storage.read(key: 'storeId');
                String? userId = await _storage.read(key: 'userId');
                int brandId = int.tryParse(brandIdStr ?? '') ?? 0;
                int storeId = int.tryParse(storeIdStr ?? '') ?? 0;
                print("Token retrieved: $token");
                print("brand id : $brandId");
                print("store id: $storeId");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DashBoardScreen(
                          token: token ?? '',
                          brandId: brandId,
                          storeId: storeId,
                          userId: userId ?? '')),
                );
              }),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () async {
              String? storeIdStr = await _storage.read(key: 'storeId');
              int storeId = int.tryParse(storeIdStr ?? '') ?? 0;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(
                          storeId: storeId,
                        )),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('About us'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text('Support'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            title: Text('Logout'),
            leading: Icon(Icons.exit_to_app),
            onTap: () async {
              await _storage.deleteAll();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
