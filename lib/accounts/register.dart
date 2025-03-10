import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:group1_flutter/constants/api_endpoints.dart';
import 'package:group1_flutter/models/register_model.dart';
import 'package:group1_flutter/shared/error_dialog.dart';
import 'package:group1_flutter/shared/submit_button.dart';
import 'package:group1_flutter/shared/test_fields.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      final registerData = RegisterModel(
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneNumberController.text,
      );

      var result = await http.post(
        Uri.parse(ApiEndpoints.register),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(registerData.toJson()),
      );

      if (result.statusCode >= 200 && result.statusCode <= 299) {
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        var errorData = jsonDecode(result.body);
        int statusCode = errorData['status'];
        String title = errorData['title'];

        if (!mounted) return;

        errorDialog(
          context: context,
          statusCode: statusCode,
          description: title,
          color: Colors.green,
        );
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/Bp/BackgroundP.jpg', // Adjust path if necessary
              fit: BoxFit.cover,
            ),
          ),
          // Login Form
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "TUTURIO.",
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            const SizedBox(height: 50),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    emailTextField(emailController: _emailController),
                    const SizedBox(height: 10),
                    passwordTextField(passwordController: _passwordController),
                    const SizedBox(height: 10),
                    phoneNumberField(
                        phoneNumberController: _phoneNumberController),
                    const SizedBox(height: 10),
                    submitButton(
                      context: context,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      title: "Register",
                      method: submitForm,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                text: "Already have an account? ",
                style: const TextStyle(color: Colors.black87),
                children: [
                  TextSpan(
                    text: "Login Here",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pop();
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        ],
      ));
  }
}
