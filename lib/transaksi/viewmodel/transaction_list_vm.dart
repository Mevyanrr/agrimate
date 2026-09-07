import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:flutter/material.dart';

enum TransactionLoadState { loading, loaded, error }

class TransactionListViewModel extends ChangeNotifier {
  final UserRole role;
  final BackendDependencies _backend = BackendDependencies.create();

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

  void onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          isPetani ? '/home-petani' : '/home-pembeli',
        );
        break;
      case 1:
        if (isPetani) Navigator.pushReplacementNamed(context, '/pasar');
        break;
      case 2:
        if (isPetani) Navigator.pushReplacementNamed(context, '/rencana-panen');
        break;
      case 3:
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profil', arguments: role);
        break;
    }
  }

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
}
