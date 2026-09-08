import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:agrimate/backend/features/demand/domain/entities/demand_forecast.dart';
import 'package:agrimate/backend/features/supply/domain/entities/supply_forecast.dart';
import 'package:agrimate/petani_features/home/data/rencana_panen.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:agrimate/petani_features/rencana_panen/model/rencana_panen.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

enum RencanaPanenLoadState { loading, loaded, error }

class RencanaPanenViewModel extends ChangeNotifier {
  final UserRole role;
  final BackendDependencies _backend = BackendDependencies.create();

  RencanaPanenLoadState _state = RencanaPanenLoadState.loading;
  RencanaPanenLoadState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RencanaPanenDataModel? _data;
  RencanaPanenDataModel? get data => _data;

  int _currentNavIndex = 2;
  int get currentNavIndex => _currentNavIndex;

  bool get isPetani => role == UserRole.petani;

  RencanaPanenViewModel({required this.role}) {
    fetchRencanaData();
  }

  Future<void> fetchRencanaData() async {
    _state = RencanaPanenLoadState.loading;
    notifyListeners();

    try {
      final commoditiesResult = await _backend.commodityRepository
          .getCommodities();
      final names = commoditiesResult is Success<List<Commodity>>
          ? {for (final item in commoditiesResult.data) item.id: item.name}
          : <String, String>{};

      if (isPetani) {
        final result = await _backend.supplyRepository.getMine();
        if (result case Failure(message: final message)) {
          throw Exception(message);
        }
        final values = (result as Success<List<SupplyForecast>>).data;
        _data = RencanaPanenDataModel(
          plans: values.map((item) {
            final name = names[item.commodityId] ?? 'Komoditas';
            return _forecastPlan(
              id: item.id,
              name: name,
              quantity: item.quantity,
              remaining: item.remainingQuantity,
              start: item.harvestStartDate,
              end: item.harvestEndDate,
            );
          }).toList(),
        );
      } else {
        final result = await _backend.demandRepository.getMine();
        if (result case Failure(message: final message)) {
          throw Exception(message);
        }
        final values = (result as Success<List<DemandForecast>>).data;
        _data = RencanaPanenDataModel(
          plans: values.map((item) {
            final name = names[item.commodityId] ?? 'Komoditas';
            return _forecastPlan(
              id: item.id,
              name: name,
              quantity: item.quantity,
              remaining: item.remainingQuantity,
              start: item.neededStartDate,
              end: item.neededEndDate,
            );
          }).toList(),
        );
      }

      _state = RencanaPanenLoadState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Coba lagi.';
      _state = RencanaPanenLoadState.error;
    }
    notifyListeners();
  }

  Future<void> onRefresh() => fetchRencanaData();

  HarvestPlanModel _forecastPlan({
    String? id,
    required String name,
    required num quantity,
    required num? remaining,
    required DateTime start,
    required DateTime end,
  }) {
    final total = quantity.toDouble();
    final left = remaining?.toDouble() ?? total;
    return HarvestPlanModel(
      id: id ?? '',
      commodityName: name,
      commodityEmoji: _emojiFor(name),
      dateRangeLabel: '${_date(start)} - ${_date(end)}',
      totalWeightKg: total,
      allocatedWeightKg: (total - left).clamp(0, total),
      hasMatch: left < total,
    );
  }

  void onNavTap(BuildContext context, int index) {
    if (index == _currentNavIndex) return;
    _currentNavIndex = index;
    notifyListeners();

    if (!context.mounted) return;

    switch (index) {
      case 0:
        final targetHome = isPetani ? '/home-petani' : '/home-pembeli';
        Navigator.pushReplacementNamed(context, targetHome, arguments: role);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/pasar', arguments: role);
        break;
      case 2:
        final targetMenu = isPetani
            ? '/rencana-panen'
            : '/rencana-panen-pembeli';
        Navigator.pushReplacementNamed(context, targetMenu, arguments: role);
        break;
      case 3:
        final targetTransaksi = isPetani ? '/transaksi' : '/transaksi-pembeli';
        Navigator.pushReplacementNamed(
          context,
          targetTransaksi,
          arguments: role,
        );
        break;
      case 4:
        final targetProfil = isPetani ? '/profil' : '/profil-pembeli';
        Navigator.pushReplacementNamed(context, targetProfil, arguments: role);
        break;
    }
  }

  // Arahkan ke rute yang sesuai berdasarkan role pengguna
  void onAddPlanPressed(BuildContext context) {
    if (isPetani) {
      Navigator.pushNamed(context, '/tambah-rencana');
    } else {
      Navigator.pushNamed(context, '/rencana-kebutuhan-baru');
    }
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

class RencanaViewModel extends ChangeNotifier {
  RencanaViewModel({RencanaRepository? repository, required this.role})
    : _repository = repository ?? RencanaRepositoryImpl() {
    _loadCommodities();
  }

  final RencanaRepository _repository;
  final UserRole role;

  final PageController pageController = PageController();
  static const int totalSteps = 4;

  int _currentStep = 0;
  int get currentStep => _currentStep;

  // PAGE 1 — Pilih Komoditas
  List<KomoditasModel> komoditasList = [];
  KomoditasModel? selectedKomoditas;

  final TextEditingController customKomoditasController =
      TextEditingController();
  String customKomoditasName = '';

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

    if (komoditas.id != 'lainnya') {
      customKomoditasController.clear();
      customKomoditasName = '';
    }

    notifyListeners();
    _repository.saveDraft({'step': 1, 'komoditas_id': komoditas.id});
  }

  void setCustomKomoditasName(String value) {
    customKomoditasName = value;
    notifyListeners();
    _repository.saveDraft({
      'step': 1,
      'komoditas_id': 'lainnya',
      'komoditas_custom_name': value,
    });
  }

  bool get isPage1Valid {
    if (selectedKomoditas == null) return false;
    if (selectedKomoditas?.id == 'lainnya') {
      return customKomoditasName.trim().isNotEmpty;
    }
    return true;
  }

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

  // PAGE 3 — Pilih Tanggal Panen
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
      // Do nothing
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
  String? submittedAddress;

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
      final profileResult = await BackendDependencies.create().profileRepository
          .getMine();
      if (profileResult case Success(data: final profile?)) {
        submittedAddress = profile.address;
      }
      return await _repository.submitRencana(payload, role);
    } catch (error) {
      submitError = error.toString();
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

  void onSettingsPressed(BuildContext context) {
    Navigator.pushNamed(context, '/pengaturan');
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
  if (value.contains('kentang')) return '🥔';
  return '🌾';
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
