import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:flutter/material.dart';

enum TransactionLoadState { loading, loaded, error }

class TransactionListViewModel extends ChangeNotifier {
  final UserRole role;
  final BackendDependencies _backend = BackendDependencies.create();
  int _currentNavIndex = 3;

  TransactionListViewModel({required this.role}) {
    fetchTransactions();
  }

  TransactionLoadState _state = TransactionLoadState.loading;
  TransactionLoadState get state => _state;

  TransactionSummaryModel? _summary;
  TransactionSummaryModel? get summary => _summary;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
      final result = await _backend.transactions.getMine();
      switch (result) {
        case Success(data: final transactions):
          _allTransactions = transactions.map((transaction) {
            final data = Map<String, dynamic>.from(transaction.data);
            data['id'] ??= transaction.id;
            data['counterparty_label'] ??= isPetani ? 'Pembeli' : 'Petani';
            return TransactionModel.fromJson(data);
          }).toList();
        case Failure(message: final message):
          throw Exception(message);
      }

      _recalculateSummary();

      _errorMessage = null;
      _state = TransactionLoadState.loaded;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      _state = TransactionLoadState.error;
    }
    notifyListeners();
  }

  void _recalculateSummary() {
    final completed = _allTransactions
        .where((item) => item.status == TransactionStatus.done)
        .toList();
    _summary = TransactionSummaryModel(
      totalTransactions: _allTransactions.length,
      completedCount: completed.length,
      waitingCount: _allTransactions
          .where((item) => item.status == TransactionStatus.waiting)
          .length,
      totalValue: completed.fold(0, (total, item) => total + item.totalPrice),
    );
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
          _recalculateSummary();
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