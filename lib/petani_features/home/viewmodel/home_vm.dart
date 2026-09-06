import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:agrimate/backend/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:agrimate/backend/features/profile/domain/entities/profile_entity.dart';
import 'package:agrimate/backend/features/supply/domain/entities/supply_forecast.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum HomeLoadState { loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final BackendDependencies _backend = BackendDependencies.create();
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

  HomeViewModel() {
    fetchHomeData();
  }

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

      final profile = profileResult is Success<ProfileEntity?>
          ? profileResult.data
          : null;
      _profileIncomplete = profile == null || profile.fullName.trim().isEmpty;
      final summary = summaryResult is Success<DashboardSummary>
          ? summaryResult.data
          : const DashboardSummary(
              role: 'FARMER',
              activeForecasts: 0,
              potentialMatches: 0,
              transactions: 0,
              transactionValue: 0,
            );
      final supplies = suppliesResult is Success<List<SupplyForecast>>
          ? suppliesResult.data
          : <SupplyForecast>[];
      final commodityNames = commoditiesResult is Success<List<Commodity>>
          ? {for (final item in commoditiesResult.data) item.id: item.name}
          : <String, String>{};
      Map<String, dynamic>? farmerDetails;
      try {
        farmerDetails = await Supabase.instance.client
            .from('farmer_details')
            .select('land_address, land_photo_path')
            .eq('user_id', userId)
            .maybeSingle();
      } catch (error) {
        debugPrint('Home/farmer_details: $error');
      }
      final landAddress = farmerDetails?['land_address']?.toString().trim();
      _profileIncomplete =
          _profileIncomplete || landAddress == null || landAddress.isEmpty;

      _data = HomeDataModel(
        profile: FarmerProfileModel(
          photoUrl: null,
          name: profile?.fullName.isNotEmpty == true
              ? profile!.fullName
              : 'Petani',
          location: landAddress ?? '-',
        ),
        summary: HomeSummaryModel(
          activePlans: summary.activeForecasts,
          totalAllocatedKg: supplies.fold<double>(0, (total, item) {
            final remaining =
                item.remainingQuantity?.toDouble() ?? item.quantity.toDouble();
            return total +
                (item.quantity.toDouble() - remaining).clamp(
                  0,
                  item.quantity.toDouble(),
                );
          }),
          completedTransactions: summary.transactions,
        ),
        buyerMatch: BuyerMatchModel(matchCount: summary.potentialMatches),
        recentPlans: supplies.take(3).map((item) {
          final name = commodityNames[item.commodityId] ?? 'Komoditas';
          final remaining =
              item.remainingQuantity?.toDouble() ?? item.quantity.toDouble();
          return HarvestPlanModel(
            id: item.id ?? '',
            commodityName: name,
            commodityEmoji: _emojiFor(name),
            dateRangeLabel:
                '${_date(item.harvestStartDate)} - ${_date(item.harvestEndDate)}',
            totalWeightKg: item.quantity.toDouble(),
            allocatedWeightKg: (item.quantity.toDouble() - remaining).clamp(
              0,
              item.quantity.toDouble(),
            ),
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
    Navigator.pushNamed(context, '/tambah-rencana');
  }

  void onSeeAllPlansPressed(BuildContext context) {
    Navigator.pushNamed(context, '/rencana-panen');
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
