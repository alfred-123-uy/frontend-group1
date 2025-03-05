import 'package:flutter/material.dart';
import 'package:group1_flutter/accounts/login.dart';
import 'package:group1_flutter/admin_area/add_role.dart';
import 'package:group1_flutter/admin_area/add_user.dart';
import 'package:group1_flutter/admin_area/change_admin_password.dart';
import 'package:group1_flutter/admin_area/edit_profile.dart';
import 'package:group1_flutter/admin_area/get_roles.dart';
import 'package:group1_flutter/admin_area/get_users.dart';
import 'package:group1_flutter/admin_area/select_user.dart';
import 'package:group1_flutter/constants/app_colors.dart';
import 'package:group1_flutter/constants/token_handler.dart';
import 'package:group1_flutter/services/fetch_email.dart';
import 'package:group1_flutter/services/role_check.dart';
import 'package:group1_flutter/shared/custom_appbar.dart';
import 'package:group1_flutter/shared/submit_button.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  List<Map<String, dynamic>> buttons = [];
  late String email;

  @override
  void initState() {
    RoleCheck().checkAdminRole(context);
    email = fetchEmailFromToken(context: context);
    addButtonData(context);
    super.initState();
  }

  void addButtonData(BuildContext context) {
    buttons.addAll(
      [
        {
          'title': 'Show Users',
          'backgroundColor': AppColors.adminPage,
          'textColor': Colors.white,
          'onPressed': () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GetUsers()));
          }
        },
        {
          'title': 'Add New Users',
          'backgroundColor': AppColors.adminPage,
          'textColor': Colors.white,
          'onPressed': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddUser(),
              ),
            );
          },
        },
        {
          'title': 'Show Roles',
          'backgroundColor': AppColors.adminPage,
          'textColor': Colors.white,
          'onPressed': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const GetRoles(),
              ),
            );
          },
        },
        {
          'title': 'Add New Roles',
          'backgroundColor': AppColors.adminPage,
          'textColor': Colors.white,
          'onPressed': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddRole(),
              ),
            );
          },
        },
        {
          'title': 'Change User Roles',
          'backgroundColor': AppColors.adminPage,
          'textColor': Colors.white,
          'onPressed': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectUser(),
              ),
            );
          },
        },
        {
          'title': 'Edit Profile',
          'backgroundColor': AppColors.adminPage,
          'textColor': Colors.white,
          'onPressed': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfile(
                  email: email,
                ),
              ),
            );
          },
        },
        {
          'title': 'Change Password',
          'backgroundColor': AppColors.adminPage,
          'textColor': Colors.white,
          'onPressed': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChangeAdminPassword(
                  email: email,
                ),
              ),
            );
          },
        },
        {
          'title': 'Logout',
          'backgroundColor': AppColors.adminPage,
          'textColor': Colors.white,
          'onPressed': () {
            TokenHandler().clearToken();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (Route<dynamic> route) => false,
            );
          },
        },
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
          title: "Admin Section", color: AppColors.adminPage),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Admin Methods"),
            const SizedBox(height: 20),
            ListView.builder(
              itemCount: buttons.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    submitButton(
                      context: context,
                      backgroundColor: buttons[index]['backgroundColor'],
                      textColor: buttons[index]['textColor'],
                      title: buttons[index]['title'],
                      method: buttons[index]['onPressed'],
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
