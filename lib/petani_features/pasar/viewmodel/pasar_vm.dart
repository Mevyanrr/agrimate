import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:agrimate/backend/features/demand/domain/entities/demand_forecast.dart';
import 'package:flutter/material.dart';
import '../model/pasar.dart';

enum PasarLoadState { loading, loaded, error }

class PasarViewModel extends ChangeNotifier {
  final BackendDependencies _backend = BackendDependencies.create();
  PasarViewModel() {
    fetchPasarData();
  }

  PasarLoadState _state = PasarLoadState.loading;
  PasarLoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CommodityFilterModel> _commodityFilters = [];
  List<CommodityFilterModel> get commodityFilters => _commodityFilters;

  List<BuyerRequestModel> _allRequests = [];

  String _selectedCommodityId = 'semua';
  String get selectedCommodityId => _selectedCommodityId;

  PasarTimelineFilter _selectedTimeline = PasarTimelineFilter.semua;
  PasarTimelineFilter get selectedTimeline => _selectedTimeline;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  final int currentNavIndex = 1;

  Future<void> fetchPasarData() async {
    _state = PasarLoadState.loading;
    notifyListeners();

    try {
      final demandResult = await _backend.demandRepository.getMarketplace();
      final commodityResult = await _backend.commodityRepository
          .getCommodities();
      if (demandResult case Failure(message: final message))
        throw Exception(message);
      if (commodityResult case Failure(message: final message))
        throw Exception(message);
      final demands = (demandResult as Success<List<DemandForecast>>).data;
      final commodities = (commodityResult as Success<List<Commodity>>).data;
      final commodityById = {for (final item in commodities) item.id: item};

      _commodityFilters = [
        const CommodityFilterModel(id: 'semua', label: 'Semua'),
        ...commodities.map(
          (item) => CommodityFilterModel(id: item.id, label: item.name),
        ),
      ];
      _allRequests = demands.map((item) {
        final commodity = commodityById[item.commodityId];
        final name = commodity?.name ?? 'Komoditas';
        return BuyerRequestModel(
          id: item.id ?? '',
          commodityId: item.commodityId,
          commodityName: name,
          commodityEmoji: _marketEmoji(name),
          buyerType: BuyerType.distributor,
          buyerName: 'Pembeli AgriMate',
          location: item.deliveryAddress,
          quantityKg: (item.remainingQuantity ?? item.quantity).toDouble(),
          periodLabel:
              '${_shortDate(item.neededStartDate)} - ${_shortDate(item.neededEndDate)}',
          pricePerKg: commodity?.price ?? 0,
          neededDate: item.neededStartDate,
        );
      }).toList();

      _state = PasarLoadState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Coba lagi.';
      _state = PasarLoadState.error;
    }
    notifyListeners();
  }

  Future<void> onRefresh() => fetchPasarData();

  List<BuyerRequestModel> get filteredRequests {
    final query = _searchQuery.trim().toLowerCase();

    return _allRequests.where((request) {
      final matchesCommodity =
          _selectedCommodityId == 'semua' ||
          request.commodityId == _selectedCommodityId;

      final matchesTimeline = _matchesTimeline(request.neededDate);

      final matchesQuery =
          query.isEmpty ||
          request.commodityName.toLowerCase().contains(query) ||
          request.buyerName.toLowerCase().contains(query);

      return matchesCommodity && matchesTimeline && matchesQuery;
    }).toList();
  }

  bool _matchesTimeline(DateTime date) {
    final now = DateTime.now();
    switch (_selectedTimeline) {
      case PasarTimelineFilter.semua:
        return true;
      case PasarTimelineFilter.mingguIni:
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final day = DateTime(date.year, date.month, date.day);
        return !day.isBefore(startOfWeek) && !day.isAfter(endOfWeek);
      case PasarTimelineFilter.bulanIni:
        return date.year == now.year && date.month == now.month;
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void selectCommodity(String id) {
    if (id == _selectedCommodityId) return;
    _selectedCommodityId = id;
    notifyListeners();
  }

  void selectTimeline(PasarTimelineFilter filter) {
    if (filter == _selectedTimeline) return;
    _selectedTimeline = filter;
    notifyListeners();
  }

  Future<void> onApplyPressed(BuyerRequestModel request) async {
    if (request.isApplied) return;

    final index = _allRequests.indexWhere((r) => r.id == request.id);
    if (index == -1) return;

    _allRequests[index] = _allRequests[index].copyWith(isApplied: true);
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      _allRequests[index] = _allRequests[index].copyWith(isApplied: false);
      notifyListeners();
    }
  }

  void onDetailPressed(BuildContext context, BuyerRequestModel request) {
    Navigator.pushNamed(context, '/pasar/detail', arguments: request.id);
  }

  void onNotificationPressed(BuildContext context) {
    Navigator.pushNamed(context, '/notifikasi');
  }

  void onSettingsPressed(BuildContext context) {
    Navigator.pushNamed(context, '/pengaturan');
  }

  void onNavTap(BuildContext context, int index) {
    if (index == currentNavIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home-petani');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/rencana-panen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/transaksi');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }
}

String _marketEmoji(String name) {
  final value = name.toLowerCase();
  if (value.contains('tomat')) return '🍅';
  if (value.contains('cabai')) return '🌶️';
  if (value.contains('jagung')) return '🌽';
  if (value.contains('bawang')) return '🧅';
  if (value.contains('bayam') || value.contains('sawi')) return '🥬';
  return '🌾';
}

String _shortDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
