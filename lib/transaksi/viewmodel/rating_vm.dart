import 'package:flutter/material.dart';

class RatingViewModel extends ChangeNotifier {
  int _selectedStars = 0;
  int get selectedStars => _selectedStars;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get canSubmit => _selectedStars > 0;

  void onStarTapped(int starIndex) {
    _selectedStars = starIndex;
    notifyListeners();
  }

  Future<bool> onSubmitPressed() async {
    if (!canSubmit) return false;

    _isSubmitting = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    _isSubmitting = false;
    notifyListeners();
    return true;
  }
}