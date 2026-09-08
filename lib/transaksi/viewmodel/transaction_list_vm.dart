import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:flutter/material.dart';

enum TransactionLoadState { loading, loaded, error }

class TransactionListViewModel extends ChangeNotifier {
  final UserRole role;
  int _currentNavIndex = 3;

  TransactionListViewModel({required this.role}) {
    fetchTransactions();
  }

  TransactionLoadState _state = TransactionLoadState.loading;
  TransactionLoadState get state => _state;

  TransactionSummaryModel? _summary;
  TransactionSummaryModel? get summary => _summary;

  List<TransactionModel> _allTransactions = [];

  TransactionFilter _activeFilter = TransactionFilter.all;
  TransactionFilter get activeFilter => _activeFilter;

  List<TransactionModel> get filteredTransactions =>
      _allTransactions.where((t) => _activeFilter.matches(t.status)).toList();

  bool get isPetani => role == UserRole.petani;
  String get totalValueLabel =>
      isPetani ? 'Total Nilai Penjualan' : 'Total Nilai Pembelian';

  void onFilterChanged(TransactionFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _state = TransactionLoadState.loading;
    notifyListeners();

    try {

      await Future.delayed(const Duration(milliseconds: 500));

      _summary = const TransactionSummaryModel(
        totalTransactions: 4,
        completedCount: 2,
        waitingCount: 1,
        totalValue: 29725000,
      );

      _allTransactions = [
        TransactionModel(
          id: 'trx_1',
          commodityName: 'Jagung',
          commodityEmoji: '🌽',
          weightKg: 150,
          transactionDateLabel: '21 Agustus 2026',
          counterpartyLabel: 'Ke Restoran Sate Khas',
          totalPrice: 1275000,
          status: TransactionStatus.waiting,
          unitPrice: 8500,
          subtotal: 8500,
          serviceFeePercent: 5,
          serviceFee: 63750,
          totalReceived: 1211250,
          deliveryDateLabel: '25 Agu 2026',
          deliveryAddress: 'Jl. Pemuda No. 42, Semarang',
          phoneNumber: '081234567890',
          whatsappNumber: '081234567890',
        ),
        TransactionModel(
          id: 'trx_2',
          commodityName: 'Jagung',
          commodityEmoji: '🌽',
          weightKg: 150,
          transactionDateLabel: '21 Agustus 2026',
          counterpartyLabel: 'Ke Restoran Sate Khas',
          totalPrice: 1275000,
          status: TransactionStatus.confirmed,
          unitPrice: 8500,
          subtotal: 8500,
          serviceFeePercent: 5,
          serviceFee: 63750,
          totalReceived: 1211250,
          deliveryDateLabel: '25 Agu 2026',
          deliveryAddress: 'Jl. Pemuda No. 42, Semarang',
          phoneNumber: '081234567890',
          whatsappNumber: '081234567890',
        ),
        TransactionModel(
          id: 'trx_3',
          commodityName: 'Jagung',
          commodityEmoji: '🌽',
          weightKg: 150,
          transactionDateLabel: '21 Agustus 2026',
          counterpartyLabel: 'Ke Restoran Sate Khas',
          totalPrice: 1275000,
          status: TransactionStatus.done,
          unitPrice: 8500,
          subtotal: 8500,
          serviceFeePercent: 5,
          serviceFee: 63750,
          totalReceived: 1211250,
          deliveryDateLabel: '25 Agu 2026',
          deliveryAddress: 'Jl. Pemuda No. 42, Semarang',
          phoneNumber: '081234567890',
          whatsappNumber: '081234567890',
          ratingGiven: null,
        ),
        TransactionModel(
          id: 'trx_4',
          commodityName: 'Jagung',
          commodityEmoji: '🌽',
          weightKg: 150,
          transactionDateLabel: '21 Agustus 2026',
          counterpartyLabel: 'Ke Restoran Sate Khas',
          totalPrice: 1275000,
          status: TransactionStatus.cancelled,
          unitPrice: 8500,
          subtotal: 8500,
          serviceFeePercent: 5,
          serviceFee: 63750,
          totalReceived: 1211250,
          cancelDateLabel: '25 Agu 2026',
          cancelReason: 'Pembeli berubah pikiran',
        ),
      ];

      _state = TransactionLoadState.loaded;
    } catch (e) {
      _state = TransactionLoadState.error;
    }
    notifyListeners();
  }

  Future<void> onRefresh() => fetchTransactions();

  void onTransactionTapped(BuildContext context, TransactionModel trx) {
    Navigator.pushNamed(
      context,
      '/transaction-detail',
      arguments: {'role': role, 'transaction': trx},
    ).then((result) {
      if (result is TransactionModel) {
        final index = _allTransactions.indexWhere((t) => t.id == result.id);
        if (index != -1) {
          _allTransactions[index] = result;
          notifyListeners();
        }
      }
    });
  }

  
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
      final targetMenu = (role == UserRole.petani) ? '/rencana-panen' : '/rencana-panen-pembeli';
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
}