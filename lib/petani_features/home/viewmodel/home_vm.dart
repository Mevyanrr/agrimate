import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:flutter/material.dart';

enum HomeLoadState { loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  HomeLoadState _state = HomeLoadState.loading;
  HomeLoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeDataModel? _data;
  HomeDataModel? get data => _data;

  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  HomeViewModel() {
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    _state = HomeLoadState.loading;
    notifyListeners();

    try {

      await Future.delayed(const Duration(milliseconds: 600)); 

      _data = HomeDataModel(
        profile: const FarmerProfileModel(
          photoUrl: null,
          name: 'Pak Tian',
          location: 'Malang, Jawa Timur',
        ),
        summary: const HomeSummaryModel(
          activePlans: 5,
          totalAllocatedKg: 850,
          completedTransactions: 12,
        ),
        buyerMatch: const BuyerMatchModel(matchCount: 1),
        recentPlans: const [
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
        ],
      );

      _state = HomeLoadState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Coba lagi.';
      _state = HomeLoadState.error;
    }
    notifyListeners();
  }

  Future<void> onRefresh() => fetchHomeData();

  void onNavTap(BuildContext context, int index) {
    if (index == _currentNavIndex) return;
    _currentNavIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        break; 
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

  void onNotificationPressed(BuildContext context) {
    Navigator.pushNamed(context, '/notifikasi');
  }

  void onSettingsPressed(BuildContext context) {
    Navigator.pushNamed(context, '/pengaturan');
  }

  void onBuyerMatchPressed(BuildContext context) {
    Navigator.pushNamed(context, '/kecocokan-pembeli');
  }

  void onCreatePlanPressed(BuildContext context) {
    Navigator.pushNamed(context, '/rencana-panen/buat');
  }

  void onSeeAllPlansPressed(BuildContext context) {
    Navigator.pushNamed(context, '/rencana-panen');
  }

  void onPlanCardPressed(BuildContext context, HarvestPlanModel plan) {
    Navigator.pushNamed(context, '/rencana-panen/detail', arguments: plan.id);
  }
}