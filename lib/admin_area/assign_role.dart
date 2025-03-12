import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:group1_flutter/admin_area/admin_main_page.dart';
import 'package:group1_flutter/constants/api_endpoints.dart';
import 'package:group1_flutter/constants/app_colors.dart';
import 'package:group1_flutter/constants/border_styles.dart';
import 'package:group1_flutter/constants/token_handler.dart';
import 'package:group1_flutter/models/change_role_model.dart';
import 'package:group1_flutter/models/role_model.dart';
import 'package:group1_flutter/services/role_check.dart';
import 'package:group1_flutter/shared/custom_appbar.dart';
import 'package:group1_flutter/shared/error_dialog.dart';
import 'package:group1_flutter/shared/submit_button.dart';
import 'package:group1_flutter/shared/test_fields.dart';
import 'package:http/http.dart' as http;

class AssignRole extends StatefulWidget {
  final String email;
  const AssignRole({super.key, required this.email});

  @override
  State<AssignRole> createState() => _AssignRoleState();
}

class _AssignRoleState extends State<AssignRole> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedItem;
  List<RoleModel> roles = [];

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  @override
  void initState() {
    super.initState();
    RoleCheck().checkAdminRole(context);
    _emailController.text = widget.email;
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    final result = await http.get(
      Uri.parse(ApiEndpoints.adminRolesCrud),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${TokenHandler().getToken()}',
      },
    );

    if (result.statusCode >= 200 && result.statusCode <= 299) {
      final List<dynamic> jsonData = json.decode(result.body);
      setState(() {
        roles = jsonData.map((role) => RoleModel.fromJson(role)).toList();
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
      if (_selectedItem == null) {
        return;
      }

      final changeRole = ChangeRoleModel(
        userEmail: _emailController.text,
        newRole: _selectedItem!,
      );

      final result = await http.post(
        Uri.parse(ApiEndpoints.adminChangeUserRole),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${TokenHandler().getToken()}',
        },
        body: json.encode(changeRole.toJson()),
      );

      if (result.statusCode >= 200 && result.statusCode <= 299) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainPage()),
              (Route<dynamic> route) => false,
        );
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
        title: "Assign Role",
        color: AppColors.adminPage,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/Bp/BackgroundP3.jpg', // Ensure the image path is correct
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Select user to proceed",
                style: TextStyle(
                  color: Colors.white, // Ensures visibility on the background
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
                      emailTextField(
                          emailController: _emailController, readOnly: true),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: BorderStyles
                            .roleDropdownButtonFormFieldInputDecoration,
                        value: _selectedItem,
                        isExpanded: true,
                        // ignore: deprecated_member_use
                        dropdownColor: Colors.white.withOpacity(0.9), // Ensures readability
                        items: roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role.name,
                            child: Text(
                              role.name,
                              style: const TextStyle(color: Colors.black), // Ensures text visibility
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedItem = newValue;
                          });
                        },
                        validator: (value) =>
                        value == null ? 'Please select a role' : null,
                      ),
                      const SizedBox(height: 20),
                      submitButton(
                        context: context,
                        backgroundColor: AppColors.adminPage,
                        textColor: Colors.white,
                        title: "Assign Role",
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
