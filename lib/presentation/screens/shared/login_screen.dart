import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:smart_menu/config/custom_navigator.dart';
import 'package:smart_menu/presentation/widgets/custom_text_field.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  String userID;
  String userName;
  String password;
  String email;
  String roleID;
  Role role;
  bool isDeleted;

  User({
    required this.userID,
    required this.userName,
    required this.password,
    required this.email,
    required this.roleID,
    required this.role,
    required this.isDeleted,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userID: json["userID"],
        userName: json["userName"],
        password: json["password"],
        email: json["email"],
        roleID: json["roleID"],
        role: Role.fromJson(json["role"]),
        isDeleted: json["isDeleted"],
      );

  Map<String, dynamic> toJson() => {
        "userID": userID,
        "userName": userName,
        "password": password,
        "email": email,
        "roleID": roleID,
        "role": role.toJson(),
        "isDeleted": isDeleted,
      };
}

class Role {
  String roleId;
  String roleName;
  bool isDeleted;

  Role({
    required this.roleId,
    required this.roleName,
    required this.isDeleted,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        roleId: json["roleId"],
        roleName: json["roleName"],
        isDeleted: json["isDeleted"],
      );

  Map<String, dynamic> toJson() => {
        "roleId": roleId,
        "roleName": roleName,
        "isDeleted": isDeleted,
      };
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // CustomNavigator navigator = CustomNavigator();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void handlerForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        HttpClient client = HttpClient();
        client.badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
        HttpClientRequest request = await client.getUrl(
            Uri.parse('https://3.1.81.96/api/User?pageNumber=1&pageSize=10'));
        HttpClientResponse response = await request.close();

        if (response.statusCode == 200) {
          String reply = await response.transform(utf8.decoder).join();
          final List<dynamic> users = jsonDecode(reply);
          final user =
              users.map((userJson) => User.fromJson(userJson)).toList();

          final foundUser = user.firstWhere(
            (u) =>
                u.email == emailController.text &&
                u.password == passwordController.text,
            orElse: () => User(
                userID: '',
                userName: '',
                password: '',
                email: '',
                roleID: '',
                role: Role(roleId: '', roleName: '', isDeleted: false),
                isDeleted: false),
          );

          if (foundUser.userID.isNotEmpty) {
            // Login Successful
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Login successful for ${foundUser.userName}!')),
            );
          } else {
            // Login Failed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incorrect email or password')),
            );
          }
        } else {
          // Handle API errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API Error: ${response.statusCode}')),
          );
        }
      } on HandshakeException catch (e) {
        print('HandshakeException: $e'); // Print to console for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error connecting to server. Please check your network connection.')),
        );
      } catch (e) {
        // Handle other errors
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during login: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(color: Color.fromARGB(255, 0, 0, 0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(80),
              ),
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    'Login',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold),
                  ),
                  CustomTextField(
                    controller: emailController,
                    hintText: 'vodinhquyen112@gmail.com',
                    isPassword: false,
                    label: "Email",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    controller: passwordController,
                    hintText: "********",
                    isPassword: true,
                    label: "Password",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    margin: const EdgeInsets.only(top: 50),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child: TextButton(
                      onPressed: () {
                        handlerForm();
                        // navigator.navigateTo(context, AppRouter.splash);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 190, 189, 189),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      // Navigate to sign-up screen (if implemented)
                    },
                    child: const Text(
                      "Don't have any account? Sign Up",
                      style: TextStyle(
                        color: Colors.black, // Set text color to white
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
