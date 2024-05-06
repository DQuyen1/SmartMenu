import 'package:flutter/material.dart';

class UserContent extends StatefulWidget {
  const UserContent({super.key});

  @override
  State<UserContent> createState() => UserContentState();
}

class UserContentState extends State<UserContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Stack(
          // Use Stack to layer widgets
          children: [
            // Background color container
            Container(
              // padding: EdgeInsets.all(),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white, // Set your desired background color
                borderRadius:
                    BorderRadius.circular(30.0), // Adjust border radius
              ),
            ),
            ClipRRect(
              // Clip image with rounded corners
              borderRadius: BorderRadius.circular(30.0), // Adjust as desired
              child: Image.asset(
                'assets/images/user_profile.png',
                width: 100,
                height: 100,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          'Johnny Doe',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
