import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final String label;
  final String? Function(String?) validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isPassword,
    required this.label,
    required this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 2.0,
            spreadRadius: 3.0,
            offset: const Offset(3, 3.0),
          ),
        ],
      ),
      width: MediaQuery.of(context).size.width * 0.9,
      child: Material(
        child: Stack(
          children: [
            Positioned(
              top: 5,
              left: 10,
              child: Text(
                widget.label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ), // Empty label
            TextFormField(
              controller: widget.controller,
              obscureText: widget.isPassword,
              onChanged: (value) {
                widget.controller.text = value;
              },
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hintText,
                contentPadding: const EdgeInsets.fromLTRB(10, 35, 10, 15),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
