import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:agrimate/backend/features/supply/domain/entities/supply_forecast.dart';
import 'package:agrimate/petani_features/home/data/rencana_panen.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:agrimate/petani_features/rencana_panen/model/rencana_panen.dart';
import 'package:flutter/material.dart';

enum RencanaPanenLoadState { loading, loaded, error }

class RencanaPanenViewModel extends ChangeNotifier {
  final BackendDependencies _backend = BackendDependencies.create();
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
      final suppliesResult = await _backend.supplyRepository.getMine();
      final commoditiesResult = await _backend.commodityRepository
          .getCommodities();
      if (suppliesResult case Failure(message: final message)) {
        throw Exception(message);
      }
      final supplies = (suppliesResult as Success<List<SupplyForecast>>).data;
      final commodities = commoditiesResult is Success<List<Commodity>>
          ? {for (final item in commoditiesResult.data) item.id: item.name}
          : <String, String>{};
      _data = RencanaPanenDataModel(
        plans: supplies
            .map((item) => _toHarvestPlan(item, commodities[item.commodityId]))
            .toList(),
      );

      _state = RencanaPanenLoadState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Coba lagi.';
      _state = RencanaPanenLoadState.error;
    }
    notifyListeners();
  }

  Future<void> onRefresh() => fetchRencanaData();

  HarvestPlanModel _toHarvestPlan(SupplyForecast item, String? name) {
    final commodityName = name ?? 'Komoditas';
    final remaining =
        item.remainingQuantity?.toDouble() ?? item.quantity.toDouble();
    return HarvestPlanModel(
      id: item.id ?? '',
      commodityName: commodityName,
      commodityEmoji: _harvestEmoji(commodityName),
      dateRangeLabel:
          '${_formatHarvestDate(item.harvestStartDate)} - ${_formatHarvestDate(item.harvestEndDate)}',
      totalWeightKg: item.quantity.toDouble(),
      allocatedWeightKg: (item.quantity.toDouble() - remaining).clamp(
        0,
        item.quantity.toDouble(),
      ),
      hasMatch: remaining < item.quantity,
    );
  }

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
    Navigator.pushNamed(context, '/tambah-rencana');
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

String _harvestEmoji(String name) {
  final value = name.toLowerCase();
  if (value.contains('tomat')) return '🍅';
  if (value.contains('cabai')) return '🌶️';
  if (value.contains('jagung')) return '🌽';
  if (value.contains('wortel')) return '🥕';
  if (value.contains('bawang')) return '🧅';
  if (value.contains('bayam') || value.contains('sawi')) return '🥬';
  if (value.contains('kentang')) return '🥔';
  return '🌾';
}

String _formatHarvestDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

class RencanaViewModel extends ChangeNotifier {
  RencanaViewModel({RencanaRepository? repository})
    : _repository = repository ?? RencanaRepositoryImpl() {
    _loadCommodities();
  }

  final RencanaRepository _repository;

  final PageController pageController = PageController();
  static const int totalSteps = 4;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  // PAGE 1 — Pilih Komoditas
  List<KomoditasModel> komoditasList = [];
  KomoditasModel? selectedKomoditas;

  Future<void> _loadCommodities() async {
    final result = await BackendDependencies.create().commodityRepository
        .getCommodities();
    if (result case Success<List<Commodity>>(data: final items)) {
      komoditasList = items
          .map(
            (item) => KomoditasModel(
              id: item.id,
              name: item.name,
              emoji: _emojiFor(item.name),
            ),
          )
          .toList();
      notifyListeners();
    }
  }

  void selectKomoditas(KomoditasModel komoditas) {
    selectedKomoditas = komoditas;
    notifyListeners();
    _repository.saveDraft({'step': 1, 'komoditas_id': komoditas.id});
  }

  bool get isPage1Valid => selectedKomoditas != null;

  // PAGE 2 — Kuantitas (kg)
  static const double maxKuantitas = 10000;
  double kuantitas = 10;
  bool _kuantitasInteracted = false;
  void setKuantitas(double value) {
    kuantitas = value.clamp(0, maxKuantitas);
    _kuantitasInteracted = true;
    notifyListeners();
  }

  bool get isPage2Valid => _kuantitasInteracted && kuantitas > 0;

  //PAGE 3 — Pilih Tanggal Panen
  DateTime calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? tanggalMulai;
  DateTime? tanggalSelesai;

  void changeMonth(int delta) {
    calendarMonth = DateTime(calendarMonth.year, calendarMonth.month + delta);
    notifyListeners();
  }

  void setMonth(int month) {
    calendarMonth = DateTime(calendarMonth.year, month);
    notifyListeners();
  }

  void setYear(int year) {
    calendarMonth = DateTime(year, calendarMonth.month);
    notifyListeners();
  }

  void selectDate(DateTime date) {
    if (tanggalMulai == null || tanggalSelesai != null) {
      tanggalMulai = date;
      tanggalSelesai = null;
    } else if (date.isBefore(tanggalMulai!)) {
      tanggalMulai = date;
    } else if (date.isAtSameMomentAs(tanggalMulai!)) {
    } else {
      tanggalSelesai = date;
      _repository.saveDraft({
        'step': 3,
        'tanggal_mulai': tanggalMulai?.toIso8601String(),
        'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      });
    }
    notifyListeners();
  }

  int get durasiHari {
    if (tanggalMulai == null || tanggalSelesai == null) return 0;
    return tanggalSelesai!.difference(tanggalMulai!).inDays;
  }

  bool get isPage3Valid => tanggalMulai != null && tanggalSelesai != null;

  bool isSubmitting = false;
  String? submitError;

  Future<bool> submitRencana() async {
    isSubmitting = true;
    submitError = null;
    notifyListeners();

    final payload = {
      'komoditas_id': selectedKomoditas?.id,
      'komoditas_name': selectedKomoditas?.name,
      'kuantitas_kg': kuantitas.toInt(),
      'tanggal_mulai': tanggalMulai?.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'estimasi_durasi_hari': durasiHari,
    };

    try {
      return await _repository.submitRencana(payload);
    } catch (error, stackTrace) {
      debugPrint('Submit rencana gagal: $error\n$stackTrace');
      submitError = error
          .toString()
          .replaceFirst('Bad state: ', '')
          .replaceFirst('StateError: ', '');
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  bool get isCurrentStepValid {
    switch (_currentStep) {
      case 0:
        return isPage1Valid;
      case 1:
        return isPage2Valid;
      case 2:
        return isPage3Valid;
      default:
        return true;
    }
  }

  void nextPage() {
    if (!isCurrentStepValid) return;
    if (_currentStep >= totalSteps - 1) return;
    _currentStep++;
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  bool previousPage() {
    if (_currentStep == 0) return false;
    _currentStep--;
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onNotificationPressed(BuildContext context) {
    Navigator.pushNamed(context, '/notifikasi');
  }

  String _emojiFor(String name) {
    final value = name.toLowerCase();
    if (value.contains('tomat')) return '🍅';
    if (value.contains('cabai')) return '🌶️';
    if (value.contains('jagung')) return '🌽';
    if (value.contains('wortel')) return '🥕';
    if (value.contains('bawang')) return '🧅';
    if (value.contains('bayam') || value.contains('sawi')) return '🥬';
    if (value.contains('kentang')) return '🥔';
    return '🌾';
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  void onSettingsPressed(BuildContext context) {
    Navigator.pushNamed(context, '/pengaturan');
  }
}
