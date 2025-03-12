import 'package:flutter/material.dart';
import 'package:group1_flutter/accounts/login.dart';
import 'package:group1_flutter/constants/token_handler.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class RoleCheck {
  void checkAdminRole(BuildContext context) {
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role = decodedToken[
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    if (role != "Admin" || role.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void checkUserRole(BuildContext context) {
    final decodedToken = JwtDecoder.decode(TokenHandler().getToken());
    String role = decodedToken[
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

    if (role != "User" || role.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }
}