import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_menu/presentation/screens/partner/dashboard.dart';
import 'package:smart_menu/presentation/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

        HttpClientRequest request = await client.postUrl(
          Uri.parse(
              'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Auth/Login'),
        );

        request.headers.set('Content-Type', 'application/json');

        request.add(utf8.encode(json.encode({
          'userName': emailController.text,
          'password': passwordController.text,
        })));

        HttpClientResponse response = await request.close();

        if (response.statusCode == 200) {
          String reply = await response.transform(utf8.decoder).join();
          final Map<String, dynamic> responseData = jsonDecode(reply);

          final userId = responseData['userId'];
          final token = responseData['token'];
          final brandId = responseData['brandId'].toString();
          final roleId = responseData['roleId'].toString();
          final storeId = responseData['storeId'].toString();

          await _storage.write(key: 'userId', value: userId);
          await _storage.write(key: 'token', value: token);
          await _storage.write(key: 'brandId', value: brandId);
          await _storage.write(key: 'roleId', value: roleId);
          await _storage.write(key: 'storeId', value: storeId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful!'),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userId: userId,
                brandId: int.parse(brandId),
                storeId: int.parse(storeId),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Incorrect username or password')),
          );
        }
      } on HandshakeException catch (e) {
        print('HandshakeException: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error connecting to server. Please check your network connection.')),
        );
      } catch (e) {
        print('Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during login: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgroundLogin.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black45,
                  BlendMode.darken,
                )),
          ),
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
                  color: Colors.white,
                ),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        CustomTextField(
                          controller: emailController,
                          hintText: 'Enter your email',
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
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 50, 132, 186),
                                Color(0xFF16222A)
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 5.0,
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              handlerForm();
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            // Navigate to sign-up screen (if implemented)
                          },
                          child: const Text(
                            "Don't have any account? Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
