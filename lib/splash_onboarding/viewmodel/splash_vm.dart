import 'dart:async';
import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  Timer? _timer;

  void startTimer({
    required BuildContext context,
    required Duration duration,
    required String nextRoute,
  }) {
    _timer?.cancel(); 
    _timer = Timer(duration, () {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}