import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:group1_flutter/constants/api_endpoints.dart';
import 'package:group1_flutter/constants/app_colors.dart';
import 'package:group1_flutter/constants/token_handler.dart';
import 'package:group1_flutter/models/user_model.dart';
import 'package:group1_flutter/services/role_check.dart';
import 'package:group1_flutter/shared/custom_appbar.dart';
import 'package:group1_flutter/shared/error_dialog.dart';
import 'package:group1_flutter/shared/submit_button.dart';
import 'package:group1_flutter/shared/test_fields.dart';
import 'package:http/http.dart' as http;

class EditProfile extends StatefulWidget {
  final String email;
  const EditProfile({super.key, required this.email});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
  }

  @override
  void initState() {
    super.initState();
    RoleCheck().checkAdminRole(context);
    getAdminInfo(widget.email);
  }

  Future<void> getAdminInfo(String email) async {
    var result = await http.post(
      Uri.parse(ApiEndpoints.adminInfoGetAndUpdate),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${TokenHandler().getToken()}',
      },
      body: json.encode(email),
    );
    if (result.statusCode >= 200 && result.statusCode <= 299) {
      final jsonData = json.decode(result.body);
      final user = UserModel.fromJson(jsonData);

      setState(() {
        _emailController.text = user.email;
        _phoneNumberController.text = user.phoneNumber ?? "";
      });
    } else {
      var errorBody = jsonDecode(result.body);
      final error = errorBody['message'] ?? "An error occurred.";

      if (!mounted) return;

      errorDialog(
        context: context,
        statusCode: result.statusCode,
        description: error,
        color: Colors.blue,
      );
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      var result = await http.put(
        Uri.parse(ApiEndpoints.adminInfoGetAndUpdate),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenHandler().getToken()}',
        },
        body: jsonEncode({
          "email": _emailController.text,
          "phoneNumber": _phoneNumberController.text,
        }),
      );

      if (result.statusCode >= 200 && result.statusCode <= 299) {
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        var errorBody = jsonDecode(result.body);
        final error = errorBody['message'] ?? "An error occurred.";

        if (!mounted) return;

        errorDialog(
          context: context,
          statusCode: result.statusCode,
          description: error,
          color: Colors.blue,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "Admin Info",
        color: AppColors.adminPage,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/Bp/BackgroundP3.jpg', // Ensure the path is correct
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "User Details",
                style: TextStyle(
                  color: Colors.white, // Ensure visibility
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      emailTextField(
                          emailController: _emailController, readOnly: true),
                      const SizedBox(height: 20),
                      phoneNumberField(
                          phoneNumberController: _phoneNumberController),
                      const SizedBox(height: 20),
                      submitButton(
                        context: context,
                        backgroundColor: AppColors.adminPage,
                        textColor: Colors.white,
                        title: "Update",
                        method: submitForm,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
