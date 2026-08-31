import 'package:flutter/material.dart';

enum UserRole { petani, pembeli }

class RoleModel {
  final UserRole id;
  final String iconPath;
  final String title;
  final String description;
  final Color accentColor;
  final Color accentColorLight;

  const RoleModel({
    required this.id,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.accentColorLight,
  });
}