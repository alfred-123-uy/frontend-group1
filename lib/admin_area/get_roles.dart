import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:group1_flutter/constants/api_endpoints.dart';
import 'package:group1_flutter/constants/app_colors.dart';
import 'package:group1_flutter/constants/token_handler.dart';
import 'package:group1_flutter/models/role_model.dart';
import 'package:group1_flutter/services/role_check.dart';
import 'package:group1_flutter/shared/confirmation_dialog.dart';
import 'package:group1_flutter/shared/custom_appbar.dart';
import 'package:group1_flutter/shared/error_dialog.dart';
import 'package:http/http.dart' as http;

class GetRoles extends StatefulWidget {
  const GetRoles({super.key});

  @override
  State<GetRoles> createState() => _GetRolesState();
}

class _GetRolesState extends State<GetRoles> {
  List<RoleModel> roles = [];

  @override
  void initState() {
    super.initState();
    RoleCheck().checkAdminRole(context);
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

  Future<void> deleteRole({required String id}) async {
    final url = "${ApiEndpoints.adminUsersCrud}/$id";
    final result = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${TokenHandler().getToken()}',
      },
      body: jsonEncode(id),
    );

    if (result.statusCode >= 200 && result.statusCode <= 299) {
      fetchRoles();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "Add New Role",
        color: AppColors.adminPage,
      ),
      body: ListView.builder(
        itemCount: roles.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final role = roles[index];
          return ListTile(
            title: Text(role.name),
            leading: CircleAvatar(
              child: Text(
                role.name[0].toUpperCase(),
              ),
            ),
            trailing: IconButton(
              onPressed: () async {
                bool? confirmed = await showConfirmationDialog(
                  context: context,
                  title: "Confirm",
                  content: "Are you sure you want to delete this role",
                  color: AppColors.adminPage,
                );

                if (confirmed) {
                  deleteRole(id: role.id);
                } else {
                  return;
                }
              },
              icon: const Icon(Icons.delete),
            ),
          );
        },
      ),
    );
  }
}