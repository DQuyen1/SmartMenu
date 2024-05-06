import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:smart_menu/models/user.dart';
import 'package:smart_menu/presentation/screens/shared/error_screen.dart';
import 'package:smart_menu/repository/user_repository.dart';

class SampleCallAPi extends StatefulWidget {
  const SampleCallAPi({super.key});

  @override
  State<SampleCallAPi> createState() => _SampleCallAPiState();
}

class _SampleCallAPiState extends State<SampleCallAPi> {
  final UserRepository _api = UserRepository();
  late Future<List<User>> users;

  Future<List<User>> fetchData() async {
    return await _api.getAll();
  }

  @override
  void initState() {
    users = fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: users,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userList = snapshot.data!;
          if (userList.isEmpty) {
            return const Text('No users found');
          }
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ${user.name}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      'Email: ${user.email}',
                      style:
                          const TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                    // Add display for other user data if needed
                  ],
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          log(snapshot.error.toString()); // Log the error
          return const ErrorScreen();
        }
        return const Center(
            child:
                Text('Loading...')); // Replace with your custom loading widget
      },
    );
  }
}
