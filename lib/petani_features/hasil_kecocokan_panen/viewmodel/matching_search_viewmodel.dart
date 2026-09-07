import 'dart:async';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/data/matching_repository.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_result_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/rencana_summary_model.dart';
import 'package:agrimate/role_selection/model/role.dart'; 
import 'package:flutter/foundation.dart';

class MatchingSearchViewModel extends ChangeNotifier {
  MatchingSearchViewModel({
    required this.rencana,
    required this.role,
    MatchingRepository? repository,
  }) : _repository = repository ?? MatchingRepositoryImpl() {
    _startMessageCycle();
    _startSearch();
  }

  final UserRole role;
  final RencanaSummaryModel rencana;
  final MatchingRepository _repository;

  bool get isPetani => role == UserRole.petani;

  List<String> get _messages => isPetani
      ? [
          'Mencocokkan lokasi dan waktu panen...',
          'Menghitung estimasi harga pasar...',
          'Menghubungi calon pembeli terdekat...',
        ]
      : [
          'Mencocokkan kebutuhan Anda...',
          'Mencari ketersediaan stok petani...',
          'Menghubungi petani dengan panen terbaik...',
        ];

  int _messageIndex = 0;

  String get statusMessage => _messages[_messageIndex];

  Timer? _timer;

  void _startMessageCycle() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _messageIndex = (_messageIndex + 1) % _messages.length;
      notifyListeners();
    });
  }

  MatchingResultModel? result;
  bool get isDone => result != null;

  Future<void> _startSearch() async {
    final res = await _repository.searchMatches(rencana);
    _timer?.cancel();
    result = res;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}