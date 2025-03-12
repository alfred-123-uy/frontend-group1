import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:group1_flutter/constants/api_endpoints.dart';
import 'package:group1_flutter/constants/app_colors.dart';
import 'package:group1_flutter/constants/border_styles.dart';
import 'package:group1_flutter/constants/token_handler.dart';
import 'package:group1_flutter/services/role_check.dart';
import 'package:group1_flutter/shared/custom_appbar.dart';
import 'package:group1_flutter/shared/error_dialog.dart';
import 'package:group1_flutter/shared/submit_button.dart';
import 'package:http/http.dart' as http;

class AddRole extends StatefulWidget {
  const AddRole({super.key});

  @override
  State<AddRole> createState() => _AddRoleState();
}

class _AddRoleState extends State<AddRole> {
  final TextEditingController _roleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    RoleCheck().checkAdminRole(context);
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      var result = await http.post(
        Uri.parse(ApiEndpoints.adminRolesCrud),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenHandler().getToken()}',
        },
        body: jsonEncode({'role': _roleController.text}), // Fixed JSON structure
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
        title: "Add New Role",
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
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Enter Role",
                    style: TextStyle(
                      color: Colors.white, // Adjust for better contrast
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _roleController,
                            decoration: InputDecoration(
                              labelText: 'Role',
                              labelStyle: const TextStyle(color: Colors.white), // Updated for visibility
                              floatingLabelStyle:
                              const TextStyle(color: AppColors.adminPage),
                              border: BorderStyles.border,
                              focusedBorder: BorderStyles.focusedBorder,
                              errorBorder: BorderStyles.errorBorder,
                              focusedErrorBorder: BorderStyles.focusedErrorBorder,
                            ),
                            style: const TextStyle(color: Colors.white), // Text color
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter role name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          submitButton(
                            context: context,
                            backgroundColor: AppColors.adminPage,
                            textColor: Colors.white,
                            title: "Add Role",
                            method: submitForm,
                          ),
                        ],
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
}
