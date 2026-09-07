import 'package:agrimate/core/appcolor.dart';
import 'package:flutter/material.dart';

enum PasarCardRole { petani, pembeli }

class PasarCardTheme {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color borderIdle;

  const PasarCardTheme({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.borderIdle,
  });

  static const petani = PasarCardTheme(
    primary: AppColors.greenprimary,
    primaryDark: AppColors.darkgreen,
    primaryLight: AppColors.lightgreen,
    borderIdle: AppColors.borderDefault,
  );

  static const pembeli = PasarCardTheme(
    primary: Color(0xFFFF7A00),
    primaryDark: Color(0xFFE86A00),
    primaryLight: Color(0xFFFFEFDD),
    borderIdle: Color(0xFFFFD8AE),
  );

  static PasarCardTheme of(PasarCardRole role) =>
      role == PasarCardRole.petani ? petani : pembeli;
}

String formatRupiah(double value) {
  final digits = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    final posFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}