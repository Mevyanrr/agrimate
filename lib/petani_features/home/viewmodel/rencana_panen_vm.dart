import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:agrimate/petani_features/home/model/rencana_panen.dart';
import 'package:flutter/material.dart';

enum RencanaPanenLoadState { loading, loaded, error }

class RencanaPanenViewModel extends ChangeNotifier {
  RencanaPanenLoadState _state = RencanaPanenLoadState.loading;
  RencanaPanenLoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RencanaPanenDataModel? _data;
  RencanaPanenDataModel? get data => _data;

  int _currentNavIndex = 2;
  int get currentNavIndex => _currentNavIndex;

  RencanaPanenViewModel() {
    fetchRencanaData();
  }

  Future<void> fetchRencanaData() async {
    _state = RencanaPanenLoadState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _data = const RencanaPanenDataModel(
        plans: [
          HarvestPlanModel(
            id: 'plan_1',
            commodityName: 'Tomat',
            commodityEmoji: '🍅',
            dateRangeLabel: '25 - 30 Sep 2026',
            totalWeightKg: 500,
            allocatedWeightKg: 300,
            hasMatch: true,
          ),
          HarvestPlanModel(
            id: 'plan_2',
            commodityName: 'Jagung',
            commodityEmoji: '🌽',
            dateRangeLabel: '25 - 30 Sep 2026',
            totalWeightKg: 400,
            allocatedWeightKg: 120,
            hasMatch: false,
          ),
          HarvestPlanModel(
            id: 'plan_3',
            commodityName: 'Bayam',
            commodityEmoji: '🥬',
            dateRangeLabel: '25 - 30 Sep 2026',
            totalWeightKg: 500,
            allocatedWeightKg: 0,
            hasMatch: true,
          ),
          HarvestPlanModel(
            id: 'plan_4',
            commodityName: 'Cabai Rawit',
            commodityEmoji: '🌶️',
            dateRangeLabel: '2 - 6 Okt 2026',
            totalWeightKg: 250,
            allocatedWeightKg: 250,
            hasMatch: false,
          ),
          HarvestPlanModel(
            id: 'plan_5',
            commodityName: 'Wortel',
            commodityEmoji: '🥕',
            dateRangeLabel: '10 - 14 Okt 2026',
            totalWeightKg: 300,
            allocatedWeightKg: 90,
            hasMatch: false,
          ),
        ],
      );

      _state = RencanaPanenLoadState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Coba lagi.';
      _state = RencanaPanenLoadState.error;
    }
    notifyListeners();
  }

  Future<void> onRefresh() => fetchRencanaData();

 void onNavTap(BuildContext context, int index) {
    if (index == _currentNavIndex) return;
    _currentNavIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home-petani');
      case 1:
        Navigator.pushNamed(context, '/pasar');
        break;
      case 2:
        Navigator.pushNamed(context, '/rencana-panen');
        break;
      case 3:
        Navigator.pushNamed(context, '/transaksi');
        break;
      case 4:
        Navigator.pushNamed(context, '/profil');
        break;
    }
  }

  void onAddPlanPressed(BuildContext context) {
    Navigator.pushNamed(context, '/rencana-panen');
  }

  void onNotificationPressed(BuildContext context) {
    Navigator.pushNamed(context, '/notifikasi');
  }

  void onSettingsPressed(BuildContext context) {
    Navigator.pushNamed(context, '/pengaturan');
  }

  void onPlanCardPressed(BuildContext context, HarvestPlanModel plan) {
    Navigator.pushNamed(context, '/rencana-panen/detail', arguments: plan.id);
  }
}