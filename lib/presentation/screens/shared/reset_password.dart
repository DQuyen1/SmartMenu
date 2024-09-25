// import 'package:flutter/material.dart';
// import 'package:smart_menu/repository/reset_password_handler.dart';

// class ResetPasswordPage extends StatefulWidget {
//   @override
//   _ResetPasswordPageState createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _passwordResetHandler = PasswordResetHandler();
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Reset Password')),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(labelText: 'New Password'),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a new password';
//                   }
//                   if (value.length < 8) {
//                     return 'Password must be at least 8 characters long';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: InputDecoration(labelText: 'Confirm New Password'),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value != _passwordController.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _submitResetPassword,
//                       child: Text('Reset Password'),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _submitResetPassword() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         final success = await _passwordResetHandler.resetPassword(
//           _passwordController.text,
//           _confirmPasswordController.text,
//         );
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Password reset successfully')),
//           );
//           Navigator.of(context).pushReplacementNamed('/login');
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text('Failed to reset password. Please try again.')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('An error occurred. Please try again later.')),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
// }
