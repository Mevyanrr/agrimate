import 'package:agrimate/petani_features/home/data/rencana_panen.dart';
import 'package:agrimate/petani_features/home/model/home.dart';
import 'package:agrimate/petani_features/rencana_panen/model/rencana_panen.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

enum RencanaPanenLoadState { loading, loaded, error }

class RencanaPanenViewModel extends ChangeNotifier {
  final UserRole role;

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
      await Future.delayed(const Duration(milliseconds: 600));
      _data = const RencanaPanenDataModel(
        plans: [
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
          HarvestPlanModel(
            id: 'plan_4',
            commodityName: 'Cabai Rawit',
            commodityEmoji: '🌶️',
            dateRangeLabel: '2 - 6 Okt 2026',
            totalWeightKg: 250,
            allocatedWeightKg: 250,
            hasMatch: false,
          ),
          HarvestPlanModel(
            id: 'plan_5',
            commodityName: 'Wortel',
            commodityEmoji: '🥕',
            dateRangeLabel: '10 - 14 Okt 2026',
            totalWeightKg: 300,
            allocatedWeightKg: 90,
            hasMatch: false,
          ),
        ],
      );

      _state = RencanaPanenLoadState.loaded;
    } catch (e) {
      _errorMessage = 'Gagal memuat data. Coba lagi.';
      _state = RencanaPanenLoadState.error;
    }
    notifyListeners();
  }

  Future<void> onRefresh() => fetchRencanaData();

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
    _initCommodities();
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

  final TextEditingController customKomoditasController = TextEditingController();
  String customKomoditasName = '';

  void _initCommodities() {
    komoditasList = List.from(KomoditasData.list);
    notifyListeners();
  }

  void selectKomoditas(KomoditasModel komoditas) {
    selectedKomoditas = komoditas;

    if (komoditas.id != 'lainnya') {
      customKomoditasController.clear();
      customKomoditasName = '';
    }

    notifyListeners();
  }

  void setCustomKomoditasName(String value) {
    customKomoditasName = value;
    notifyListeners();
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

  Future<bool> submitRencana() async {
    isSubmitting = true;
    notifyListeners();

    final finalKomoditasName = selectedKomoditas?.id == 'lainnya'
        ? customKomoditasName
        : selectedKomoditas?.name;

    final payload = {
      'komoditas_id': selectedKomoditas?.id,
      'komoditas_name': finalKomoditasName,
      'kuantitas_kg': kuantitas.toInt(),
      'tanggal_mulai': tanggalMulai?.toIso8601String(),
      'tanggal_selesai': tanggalSelesai?.toIso8601String(),
      'estimasi_durasi_hari': durasiHari,
    };

    final success = await _repository.submitRencana(payload);
    isSubmitting = false;
    notifyListeners();
    return success;
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
    customKomoditasController.dispose(); 
    super.dispose();
  }

  void onNotificationPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/notifikasi',
    );
  }

  void onSettingsPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/pengaturan',
    );
  }
}