import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

enum HomeLoadState { loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final UserRole role;

  HomeLoadState _state = HomeLoadState.loading;
  HomeLoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeDataModel? _data;
  HomeDataModel? get data => _data;

  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  HomeViewModel({required this.role}) {
    fetchHomeData();
  }

  bool get isPetani => role == UserRole.petani;

  Color get primaryColor =>
      isPetani ? AppColors.greenprimary : AppColors.orangeprimary;

  Color get primaryLightColor =>
      isPetani ? AppColors.lightgreen : AppColors.lightorange;

  String get roleLabel => isPetani ? 'Petani' : 'Pembeli';
  String get stat1Label => isPetani ? 'Rencana Aktif' : 'Kebutuhan Aktif';
  String get stat2Label => isPetani ? 'Total Teralokasi' : 'Terpenuhi';
  String get stat3Label => isPetani ? 'Transaksi Selesai' : 'Pesanan';

  String get matchTitle => isPetani
      ? 'Ada pembeli yang cocok, nih!'
      : 'Ada petani yang cocok, nih!';

  String get createButtonLabel =>
      isPetani ? 'Buat Rencana Panen Baru' : 'Buat Kebutuhan Baru';

  String get sectionTitle =>
      isPetani ? 'Rencana Panen Terakhir' : 'Kebutuhan Terakhir';

  Future<void> fetchHomeData() async {
    _state = HomeLoadState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      _data = HomeDataModel(
        profile: FarmerProfileModel(
          photoUrl: null,
          name: isPetani ? 'Pak Tian' : 'Budi Pembeli',
          location: 'Malang, Jawa Timur',
        ),
        summary: HomeSummaryModel(
          activePlans: 5,
          totalAllocatedKg: isPetani ? 850 : 70,
          completedTransactions: isPetani ? 12 : 8,
        ),
        buyerMatch: const BuyerMatchModel(matchCount: 1),
        recentPlans: const [
          HarvestPlanModel(
            id: 'plan_1',
            commodityName: 'Kentang',
            commodityEmoji: '🥔',
            dateRangeLabel: '25 - 30 Sep 2026',
            totalWeightKg: 500,
            allocatedWeightKg: 300,
            hasMatch: true,
          ),
          HarvestPlanModel(
            id: 'plan_2',
            commodityName: 'Tomat',
            commodityEmoji: '🍅',
            dateRangeLabel: '25 - 30 Sep 2026',
            totalWeightKg: 500,
            allocatedWeightKg: 0,
            hasMatch: false,
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
 
    if (!context.mounted) return;
 
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(
          context,
          '/pasar',
          arguments: role,
        );
        break;
      case 2:
        final targetMenu = isPetani ? '/rencana-panen' : '/rencana-panen-pembeli';
        Navigator.pushReplacementNamed(context, targetMenu, arguments: role);
        break;
      case 3:
        final targetTransaksi = isPetani ? '/transaksi' : '/transaksi-pembeli';
        Navigator.pushReplacementNamed(context, targetTransaksi, arguments: role);
        break;
      case 4:
        final targetProfil = isPetani ? '/profil' : '/profil-pembeli';
        Navigator.pushReplacementNamed(context, targetProfil, arguments: role);
        break;
    }
  }

  void onNotificationPressed(BuildContext context) {
    Navigator.pushNamed(context, '/notifikasi', arguments: role);
  }

  void onSettingsPressed(BuildContext context) {
    Navigator.pushNamed(context, '/pengaturan', arguments: role);
  }

  void onBuyerMatchPressed(BuildContext context) {
    final targetMatch = isPetani ? '/kecocokan-pembeli' : '/kecocokan-petani';
    Navigator.pushNamed(context, targetMatch, arguments: role);
  }

  void onCreatePlanPressed(BuildContext context) {
    final targetCreate = isPetani ? '/rencana-panen/buat' : '/permintaan-saya/buat';
    Navigator.pushNamed(context, targetCreate, arguments: role);
  }

  void onSeeAllPlansPressed(BuildContext context) {
    final targetList = isPetani ? '/rencana-panen' : '/permintaan-saya';
    Navigator.pushNamed(context, targetList, arguments: role);
  }

  void onPlanCardPressed(BuildContext context, HarvestPlanModel plan) {
    final targetDetail = isPetani ? '/rencana-panen/detail' : '/permintaan-saya/detail';
    Navigator.pushNamed(context, targetDetail, arguments: plan.id);
  }
}