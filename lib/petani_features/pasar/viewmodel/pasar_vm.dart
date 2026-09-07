import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:agrimate/backend/features/demand/domain/entities/demand_forecast.dart';
import 'package:agrimate/backend/features/matches/domain/entities/market_match.dart';
import 'package:agrimate/backend/features/supply/domain/entities/supply_forecast.dart';
import 'package:flutter/material.dart';
import 'package:agrimate/role_selection/model/role.dart';
import '../model/pasar.dart';

enum PasarLoadState { loading, loaded, error }

class PasarViewModel extends ChangeNotifier {
  final BackendDependencies _backend = BackendDependencies.create();
  final UserRole role;

  PasarViewModel({required this.role}) {
    fetchPasarData();
  }

  PasarLoadState _state = PasarLoadState.loading;
  PasarLoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CommodityFilterModel> _commodityFilters = [];
  List<CommodityFilterModel> get commodityFilters => _commodityFilters;

  List<BuyerRequestModel> _allRequests = [];
  final Map<String, String> _matchIdByForecastId = {};
  final Map<String, double> _matchPriceByForecastId = {};
  final Set<String> _confirmedForecastIds = {};

  String _selectedCommodityId = 'semua';
  String get selectedCommodityId => _selectedCommodityId;

  PasarTimelineFilter _selectedTimeline = PasarTimelineFilter.semua;
  PasarTimelineFilter get selectedTimeline => _selectedTimeline;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int get currentNavIndex => 1;

  Future<void> fetchPasarData() async {
    _state = PasarLoadState.loading;
    notifyListeners();

    try {
      var demands = <DemandForecast>[];
      var supplies = <SupplyForecast>[];
      if (role == UserRole.petani) {
        final result = await _backend.demandRepository.getMarketplace();
        if (result case Failure(message: final message)) {
          throw Exception(message);
        }
        demands = (result as Success<List<DemandForecast>>).data;
      } else {
        final result = await _backend.supplyRepository.getMarketplace();
        if (result case Failure(message: final message)) {
          throw Exception(message);
        }
        supplies = (result as Success<List<SupplyForecast>>).data;
      }
      final commodityResult = await _backend.commodityRepository
          .getCommodities();
      final matchResult = await _backend.matches.getMine();
      if (commodityResult case Failure(message: final message)) {
        throw Exception(message);
      }
      if (matchResult case Failure(message: final message)) {
        throw Exception(message);
      }
      final commodities = (commodityResult as Success<List<Commodity>>).data;
      final commodityById = {for (final item in commodities) item.id: item};

      _matchIdByForecastId.clear();
      _matchPriceByForecastId.clear();
      _confirmedForecastIds.clear();
      for (final match in (matchResult as Success<List<MarketMatch>>).data) {
        final key = role == UserRole.petani ? 'demand_id' : 'supply_id';
        final forecastId = match.data[key]?.toString();
        final status = match.data['status']?.toString().toUpperCase();
        if (forecastId != null && status != 'REJECTED') {
          _matchIdByForecastId[forecastId] = match.id;
          final price = _marketNumber(match.data['reference_price']);
          if (price > 0) _matchPriceByForecastId[forecastId] = price;
          final confirmedAt = role == UserRole.petani
              ? match.data['farmer_confirmed_at']
              : match.data['buyer_confirmed_at'];
          if (confirmedAt != null || status == 'CONFIRMED') {
            _confirmedForecastIds.add(forecastId);
          }
        }
      }

      _commodityFilters = [
        const CommodityFilterModel(id: 'semua', label: 'Semua'),
        ...commodities.map(
          (item) => CommodityFilterModel(id: item.id, label: item.name),
        ),
      ];
      if (role == UserRole.petani) {
        _allRequests = demands.map((item) {
          final commodity = commodityById[item.commodityId];
          final name = commodity?.name ?? 'Komoditas';
          return BuyerRequestModel(
            id: item.id ?? '',
            commodityId: item.commodityId,
            commodityName: name,
            commodityEmoji: _marketEmoji(name),
            buyerType: BuyerType.distributor,
            buyerName: _realName(item.buyerName),
            location: item.deliveryAddress,
            quantityKg: (item.remainingQuantity ?? item.quantity).toDouble(),
            periodLabel:
                '${_shortDate(item.neededStartDate)} - ${_shortDate(item.neededEndDate)}',
            pricePerKg:
                _matchPriceByForecastId[item.id] ?? commodity?.price ?? 0,
            frequencyLabel: 'Sesuai kebutuhan',
            description:
                'Permintaan pasokan $name untuk ${item.deliveryAddress}.',
            neededDate: item.neededStartDate,
            isApplied: _confirmedForecastIds.contains(item.id),
          );
        }).toList();
      } else {
        _allRequests = supplies.map((item) {
          final commodity = commodityById[item.commodityId];
          final name = commodity?.name ?? 'Komoditas';
          return BuyerRequestModel(
            id: item.id ?? '',
            commodityId: item.commodityId,
            commodityName: name,
            commodityEmoji: _marketEmoji(name),
            buyerType: BuyerType.koperasi,
            buyerName: _realName(item.farmerName),
            location: item.address,
            quantityKg: (item.remainingQuantity ?? item.quantity).toDouble(),
            periodLabel:
                '${_shortDate(item.harvestStartDate)} - ${_shortDate(item.harvestEndDate)}',
            pricePerKg:
                _matchPriceByForecastId[item.id] ?? commodity?.price ?? 0,
            frequencyLabel: 'Sesuai ketersediaan',
            description: 'Pasokan $name tersedia dari ${item.address}.',
            neededDate: item.harvestStartDate,
            isApplied: _confirmedForecastIds.contains(item.id),
          );
        }).toList();
      }

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

    final matchId = _matchIdByForecastId[request.id];
    if (matchId == null) return;

    final result = await _backend.matches.confirm(matchId);
    if (result is Success<void>) {
      _allRequests[index] = _allRequests[index].copyWith(isApplied: true);
      notifyListeners();
    }
  }

  BuyerRequestModel? getRequestById(String id) {
    for (final request in _allRequests) {
      if (request.id == id) return request;
    }
    return null;
  }

  void onNotificationPressed(BuildContext context) {
    Navigator.pushNamed(context, '/notifikasi');
  }

  void onSettingsPressed(BuildContext context) {
    Navigator.pushNamed(context, '/pengaturan');
  }

  void onNavTap(BuildContext context, int index) {
    if (index == currentNavIndex) return;

    if (role == UserRole.petani) {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(
            context,
            '/home-petani',
            arguments: role,
          );
          break;
        case 1:
          break;
        case 2:
          Navigator.pushReplacementNamed(
            context,
            '/rencana-panen',
            arguments: role,
          );
          break;
        case 3:
          Navigator.pushReplacementNamed(
            context,
            '/transaksi',
            arguments: role,
          );
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profil', arguments: role);
          break;
      }
    } else {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(
            context,
            '/home-pembeli',
            arguments: role,
          );
          break;
        case 1:
          break;
        case 2:
          Navigator.pushReplacementNamed(
            context,
            '/rencana-panen-pembeli',
            arguments: role,
          );
          break;
        case 3:
          Navigator.pushReplacementNamed(
            context,
            '/transaksi',
            arguments: role,
          );
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profil', arguments: role);
          break;
      }
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

String _realName(String? value) {
  final name = value?.trim();
  return name == null || name.isEmpty ? 'Profil tidak tersedia' : name;
}

double _marketNumber(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;
