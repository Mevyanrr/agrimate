import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/demand/domain/entities/demand_forecast.dart';
import 'package:agrimate/backend/features/matches/domain/entities/market_match.dart';
import 'package:agrimate/backend/features/supply/domain/entities/supply_forecast.dart';
import 'package:agrimate/backend/features/transactions/domain/entities/market_transaction.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key, required this.role});
  final UserRole role;

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final _dependencies = BackendDependencies.create();
  bool _loading = true;
  List<Object> _forecasts = const [];
  List<MarketMatch> _matches = const [];
  List<MarketTransaction> _transactions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final forecastResult = widget.role == UserRole.petani
        ? await _dependencies.supplyRepository.getMine()
        : await _dependencies.demandRepository.getMine();
    final matchResult = await _dependencies.matches.getMine();
    final transactionResult = await _dependencies.transactions.getMine();
    if (!mounted) return;
    setState(() {
      _forecasts = switch (forecastResult) {
        Success(data: final List<SupplyForecast> value) => value,
        Success(data: final List<DemandForecast> value) => value,
        _ => const [],
      };
      _matches = switch (matchResult) {
        Success(data: final value) => value,
        Failure() => const [],
      };
      _transactions = switch (transactionResult) {
        Success(data: final value) => value,
        Failure() => const [],
      };
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat'),
          bottom: TabBar(
            tabs: [
              Tab(text: widget.role == UserRole.petani ? 'Supply' : 'Demand'),
              const Tab(text: 'Match'),
              const Tab(text: 'Transaksi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _HistoryList(items: _forecasts.map(_forecastData).toList()),
            _HistoryList(items: _matches.map((item) => item.data).toList()),
            _HistoryList(
              items: _transactions.map((item) => item.data).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _forecastData(Object item) => switch (item) {
    SupplyForecast value => {
      'title': '${value.quantity} kg',
      'status': value.status,
      'date': value.harvestStartDate,
    },
    DemandForecast value => {
      'title': '${value.quantity} kg',
      'status': value.status,
      'date': value.neededStartDate,
    },
    _ => const {},
  };
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text('Belum ada riwayat'));
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (_, index) {
        final item = items[index];
        final title =
            item['title'] ??
            item['transaction_number'] ??
            item['matched_quantity'] ??
            'Data #${index + 1}';
        return Card(
          child: ListTile(
            title: Text('$title'),
            subtitle: Text('${item['created_at'] ?? item['date'] ?? ''}'),
            trailing: Chip(label: Text('${item['status'] ?? '-'}')),
          ),
        );
      },
    );
  }
}
