import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:agrimate/backend/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:agrimate/backend/features/demand/domain/entities/demand_forecast.dart';
import 'package:agrimate/backend/features/profile/domain/entities/profile_entity.dart'
    show ProfileEntity;
import 'package:agrimate/backend/features/supply/domain/entities/supply_forecast.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum HomeLoadState { loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final BackendDependencies _backend = BackendDependencies.create();
  final UserRole role;
  HomeLoadState _state = HomeLoadState.loading;
  HomeLoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  HomeDataModel? _data;
  HomeDataModel? get data => _data;

  bool _profileIncomplete = false;
  bool get profileIncomplete => _profileIncomplete;

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

  String get matchTitle =>
      isPetani ? 'Ada pembeli yang cocok, nih!' : 'Ada petani yang cocok, nih!';

  String get createButtonLabel =>
      isPetani ? 'Buat Rencana Panen Baru' : 'Buat Kebutuhan Baru';

  String get sectionTitle =>
      isPetani ? 'Rencana Panen Terakhir' : 'Kebutuhan Terakhir';

  Future<void> fetchHomeData() async {
    _state = HomeLoadState.loading;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
      }
      final profileResult = await _backend.profileRepository.getMine();
      final summaryResult = await _backend.dashboardRepository.getSummary();
      final suppliesResult = await _backend.supplyRepository.getMine();
      final demandsResult = await _backend.demandRepository.getMine();
      final commoditiesResult = await _backend.commodityRepository
          .getCommodities();

      if (profileResult case Failure(message: final message)) {
        debugPrint('Home/profile: $message');
      }
      if (summaryResult case Failure(message: final message)) {
        debugPrint('Home/dashboard: $message');
      }
      if (suppliesResult case Failure(message: final message)) {
        debugPrint('Home/supplies: $message');
      }
      if (commoditiesResult case Failure(message: final message)) {
        debugPrint('Home/commodities: $message');
      }
      if (demandsResult case Failure(message: final message)) {
        debugPrint('Home/demands: $message');
      }

      final profile = profileResult is Success<ProfileEntity?>
          ? profileResult.data
          : null;
      _profileIncomplete = profile == null || profile.fullName.trim().isEmpty;
      final summary = summaryResult is Success<DashboardSummary>
          ? summaryResult.data
          : const DashboardSummary(
              role: 'UNKNOWN',
              activeForecasts: 0,
              potentialMatches: 0,
              transactions: 0,
              transactionValue: 0,
            );
      final supplies = suppliesResult is Success<List<SupplyForecast>>
          ? suppliesResult.data
          : <SupplyForecast>[];
      final demands = demandsResult is Success<List<DemandForecast>>
          ? demandsResult.data
          : <DemandForecast>[];
      final commodityNames = commoditiesResult is Success<List<Commodity>>
          ? {for (final item in commoditiesResult.data) item.id: item.name}
          : <String, String>{};
      Map<String, dynamic>? farmerDetails;
      if (isPetani) {
        try {
          farmerDetails = await Supabase.instance.client
              .from('farmer_details')
              .select('land_address, land_photo_path')
              .eq('user_id', userId)
              .maybeSingle();
        } catch (error) {
          debugPrint('Home/farmer_details: $error');
        }
      }
      final landAddress = farmerDetails?['land_address']?.toString().trim();
      if (isPetani) {
        _profileIncomplete =
            _profileIncomplete || landAddress == null || landAddress.isEmpty;
      }

      _data = HomeDataModel(
        profile: FarmerProfileModel(
          photoUrl: profile?.photoUrl,
          name: profile?.fullName.isNotEmpty == true
              ? profile!.fullName
              : roleLabel,
          location: isPetani
              ? (landAddress ?? '-')
              : (profile?.businessName ?? '-'),
        ),
        summary: HomeSummaryModel(
          activePlans: summary.activeForecasts,
          totalAllocatedKg: isPetani
              ? supplies.fold<double>(0, (total, item) {
                  final remaining =
                      item.remainingQuantity?.toDouble() ??
                      item.quantity.toDouble();
                  return total +
                      (item.quantity.toDouble() - remaining).clamp(
                        0,
                        item.quantity.toDouble(),
                      ).toDouble();
                })
              : (() {
                  final totalNeeded = demands.fold<double>(
                    0,
                    (total, item) => total + item.quantity.toDouble(),
                  );
                  final totalFulfilled = demands.fold<double>(0, (total, item) {
                    final remaining =
                        item.remainingQuantity?.toDouble() ??
                        item.quantity.toDouble();
                    return total +
                        (item.quantity.toDouble() - remaining).clamp(
                          0,
                          item.quantity.toDouble(),
                        ).toDouble();
                  });
                  return totalNeeded == 0
                      ? 0.0
                      : (totalFulfilled / totalNeeded * 100)
                          .clamp(0, 100)
                          .toDouble();
                })(),
          completedTransactions: summary.transactions,
        ),
        buyerMatch: BuyerMatchModel(matchCount: summary.potentialMatches),
        recentPlans: isPetani
            ? supplies.take(3).map((item) {
                final name = commodityNames[item.commodityId] ?? 'Komoditas';
                final remaining =
                    item.remainingQuantity?.toDouble() ??
                    item.quantity.toDouble();
                return HarvestPlanModel(
                  id: item.id ?? '',
                  commodityName: name,
                  commodityEmoji: _emojiFor(name),
                  dateRangeLabel:
                      '${_date(item.harvestStartDate)} - ${_date(item.harvestEndDate)}',
                  totalWeightKg: item.quantity.toDouble(),
                  allocatedWeightKg: (item.quantity.toDouble() - remaining)
                      .clamp(0, item.quantity.toDouble()),
                  hasMatch: remaining < item.quantity,
                );
              }).toList()
            : demands.take(3).map((item) {
                final name = commodityNames[item.commodityId] ?? 'Komoditas';
                final remaining =
                    item.remainingQuantity?.toDouble() ??
                    item.quantity.toDouble();
                return HarvestPlanModel(
                  id: item.id ?? '',
                  commodityName: name,
                  commodityEmoji: _emojiFor(name),
                  dateRangeLabel:
                      '${_date(item.neededStartDate)} - ${_date(item.neededEndDate)}',
                  totalWeightKg: item.quantity.toDouble(),
                  allocatedWeightKg: (item.quantity.toDouble() - remaining)
                      .clamp(0, item.quantity.toDouble()),
                  hasMatch: remaining < item.quantity,
                );
              }).toList(),
      );

      _state = HomeLoadState.loaded;
    } catch (e, stackTrace) {
      debugPrint('Home gagal dimuat: $e\n$stackTrace');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
        final targetHome = (role == UserRole.petani)
            ? '/home-petani'
            : '/home-pembeli';
        Navigator.pushReplacementNamed(context, targetHome, arguments: role);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/pasar', arguments: role);
        break;
      case 2:
        final targetMenu = (role == UserRole.petani)
            ? '/rencana-panen'
            : '/rencana-panen-pembeli';
        Navigator.pushReplacementNamed(context, targetMenu, arguments: role);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/transaksi', arguments: role);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profil', arguments: role);
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
    Navigator.pushNamed(context, '/pasar', arguments: role);
  }

  void onCreatePlanPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      isPetani ? '/tambah-rencana' : '/rencana-kebutuhan-baru',
    );
  }

  void onSeeAllPlansPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      isPetani ? '/rencana-panen' : '/rencana-panen-pembeli',
      arguments: role,
    );
  }

  void onPlanCardPressed(BuildContext context, HarvestPlanModel plan) {
    Navigator.pushNamed(context, '/rencana-panen/detail', arguments: plan.id);
  }
}

String _emojiFor(String name) {
  final value = name.toLowerCase();
  if (value.contains('tomat')) return '🍅';
  if (value.contains('cabai')) return '🌶️';
  if (value.contains('jagung')) return '🌽';
  if (value.contains('wortel')) return '🥕';
  if (value.contains('bawang')) return '🧅';
  if (value.contains('bayam') || value.contains('sawi')) return '🥬';
  return '🌾';
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
