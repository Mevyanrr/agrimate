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
        profile: const FarmerProfileModel(
          photoUrl: null,
          name: 'Pak Tian',
          location: 'Malang, Jawa Timur',
        ),
        summary: HomeSummaryModel(
          activePlans: 5,
          totalAllocatedKg: isPetani ? 850 : 70, // format persen jika pembeli
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

  switch (index) {
    case 0:
      final targetHome = (role == UserRole.petani) ? '/home-petani' : '/home-pembeli';
      Navigator.pushReplacementNamed(context, targetHome, arguments: role); 
      break;
    case 1:
      Navigator.pushReplacementNamed(
        context, 
        '/pasar', 
        arguments: role,
      );
      break;
    case 2:
      final targetMenu = (role == UserRole.petani) ? '/rencana-panen' : '/permintaan-saya';
      Navigator.pushReplacementNamed(context, targetMenu, arguments: role);
      break;
    case 3:
      final targetTransaksi = (role == UserRole.petani) ? '/transaksi' : '/transaksi-pembeli';
      Navigator.pushReplacementNamed(context, targetTransaksi, arguments: role);
      break;
    case 4:
      final targetProfil = (role == UserRole.petani) ? '/profil' : '/profil-pembeli';
      Navigator.pushReplacementNamed(context, targetProfil, arguments: role);
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