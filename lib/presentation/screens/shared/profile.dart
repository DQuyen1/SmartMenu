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
  final StoreRepository _storeRepository = StoreRepository();

  void _fetchStore() {
    setState(() {
      _futureStores = _storeRepository.getStoreyById(widget.storeId);
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
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: const Color.fromARGB(255, 156, 148, 168),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<Store>>(
        future: _futureStores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return buildProfile(snapshot.data!.first);
          } else {
            return const Center(child: Text('No store found.'));
          }
        },
      ),
    );
  }

  Widget buildProfile(Store store) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple.shade300,
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            store.storeName ?? 'Store Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Store Manager',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          buildInfoCard('Email', store.storeContactEmail ?? '', Icons.email),
          buildInfoCard('Phone', store.storeContactNumber ?? '', Icons.phone),
          buildInfoCard('Code', store.storeCode ?? '', Icons.code),
          buildInfoCard(
              'Location', store.storeLocation ?? '', Icons.location_on),
        ],
      ),
    );
  }

  Widget buildInfoCard(String title, String info, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title),
        subtitle: Text(info),
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

Widget buildInfoCard(String title, String info, IconData icon) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(info),
    ),
  );
}
