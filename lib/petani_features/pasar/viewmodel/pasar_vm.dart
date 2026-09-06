import 'package:flutter/material.dart';
import '../model/pasar.dart';

enum PasarLoadState { loading, loaded, error }

class PasarViewModel extends ChangeNotifier {
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
      await Future.delayed(const Duration(milliseconds: 600));
      final now = DateTime.now();

      _commodityFilters = const [
        CommodityFilterModel(id: 'semua', label: 'Semua'),
        CommodityFilterModel(id: 'tomat', label: 'Tomat'),
        CommodityFilterModel(id: 'cabai', label: 'Cabai'),
        CommodityFilterModel(id: 'bawang', label: 'Bawang'),
        CommodityFilterModel(id: 'jagung', label: 'Jagung'),
        CommodityFilterModel(id: 'bayam', label: 'Bayam'),
      ];

      _allRequests = [
        BuyerRequestModel(
          id: 'req_1',
          commodityId: 'tomat',
          commodityName: 'Tomat',
          commodityEmoji: '🍅',
          buyerType: BuyerType.restoran,
          buyerName: 'Restoran Sate Khas',
          location: 'Semarang',
          quantityKg: 150,
          periodLabel: 'Sep 2026',
          pricePerKg: 8500,
          frequencyLabel: 'Mingguan',
          description:
              'Kami butuh tomat segar setiap minggu untuk bumbu masak. '
              'Kualitas harus konsisten grade A.',
          neededDate: DateTime(now.year, now.month, now.day),
        ),
        BuyerRequestModel(
          id: 'req_2',
          commodityId: 'cabai',
          commodityName: 'Cabai Rawit',
          commodityEmoji: '🌶️',
          buyerType: BuyerType.distributor,
          buyerName: 'CV Nusantara Distributor',
          location: 'Solo',
          quantityKg: 200,
          periodLabel: 'Sep-Des 2026',
          pricePerKg: 43000,
          frequencyLabel: 'Bulanan',
          description:
              'Mencari pasokan cabai rawit rutin untuk didistribusikan ke '
              'pasar-pasar tradisional di Solo dan sekitarnya.',
          neededDate: now.add(const Duration(days: 10)),
        ),
        BuyerRequestModel(
          id: 'req_3',
          commodityId: 'bayam',
          commodityName: 'Bayam',
          commodityEmoji: '🥬',
          buyerType: BuyerType.catering,
          buyerName: 'Catering Bu Dewi',
          location: 'Yogyakarta',
          quantityKg: 50,
          periodLabel: 'Sep 2026',
          pricePerKg: 12000,
          frequencyLabel: 'Mingguan',
          description:
              'Butuh bayam segar setiap minggu untuk menu catering harian. '
              'Pengiriman pagi hari lebih diutamakan.',
          neededDate: now.add(const Duration(days: 2)),
        ),
        BuyerRequestModel(
          id: 'req_4',
          commodityId: 'jagung',
          commodityName: 'Jagung',
          commodityEmoji: '🌽',
          buyerType: BuyerType.koperasi,
          buyerName: 'Koperasi Tani Makmur',
          location: 'Malang',
          quantityKg: 300,
          periodLabel: 'Sep 2026',
          pricePerKg: 14000,
          frequencyLabel: 'Sekali Panen',
          description:
              'Menampung hasil panen jagung untuk didistribusikan ke anggota '
              'koperasi. Pembayaran langsung saat serah terima.',
          neededDate: now.add(const Duration(days: 25)),
        ),
      ];

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
      final matchesCommodity = _selectedCommodityId == 'semua' ||
          request.commodityId == _selectedCommodityId;

      final matchesTimeline = _matchesTimeline(request.neededDate);

      final matchesQuery = query.isEmpty ||
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
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
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