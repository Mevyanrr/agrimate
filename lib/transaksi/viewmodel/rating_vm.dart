import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:flutter/material.dart';

class RatingViewModel extends ChangeNotifier {
  RatingViewModel({required this.transactionId});

  final String transactionId;
  final BackendDependencies _backend = BackendDependencies.create();

  int _selectedStars = 0;
  int get selectedStars => _selectedStars;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get canSubmit => _selectedStars > 0;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void onStarTapped(int starIndex) {
    _selectedStars = starIndex;
    notifyListeners();
  }

  Future<bool> onSubmitPressed() async {
    if (!canSubmit) return false;

    _isSubmitting = true;
    notifyListeners();

    final result = await _backend.transactions.submitRating(
      transactionId: transactionId,
      rating: _selectedStars,
    );
    _isSubmitting = false;
    final success = switch (result) {
      Success() => true,
      Failure() => false,
    };
    _errorMessage = switch (result) {
      Failure(message: final message) => message,
      _ => null,
    };
    notifyListeners();
    return success;
  }
}
