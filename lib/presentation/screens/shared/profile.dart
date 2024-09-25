import 'package:flutter/material.dart';
import 'package:smart_menu/models/store.dart';
import 'package:smart_menu/repository/store_repository.dart';

class Profile extends StatefulWidget {
  final int storeId;

  const Profile({super.key, required this.storeId});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<List<Store>> _futureStores;
  final StoreRepository repository = StoreRepository();

  void _fetchStore() {
    setState(() {
      _futureStores = repository.getStoreyById(widget.storeId);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<List<Store>>(
        future: _futureStores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Store> stores = snapshot.data!;
            if (stores.isNotEmpty) {
              return buildProfile(stores);
            } else {
              return const Center(child: Text('No store found.'));
            }
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }

  Widget buildProfile(List<Store> stores) {
    if (stores.isEmpty) {
      return const Center(child: Text('No store found.'));
    } else {
      Store store = stores.first;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image(
                image: AssetImage('assets/images/user_profile.png'),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            buildProfileField('Store Name', store.storeName ?? ''),
            buildProfileField('Store Code', store.storeCode ?? ''),
            buildProfileField('Location', store.storeLocation ?? ''),
            buildProfileField('Email', store.storeContactEmail ?? ''),
            buildProfileField('Phone', store.storeContactNumber ?? ''),
          ],
        ),
      );
    }
  }

  Widget buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
