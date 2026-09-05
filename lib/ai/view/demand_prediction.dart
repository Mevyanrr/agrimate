import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/ai/domain/entities/demand_prediction.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:flutter/material.dart';
import 'package:agrimate/demand/view/create_demand.dart';

class DemandPredictionView extends StatefulWidget {
  const DemandPredictionView({super.key});
  @override
  State<DemandPredictionView> createState() => _DemandPredictionViewState();
}

class _DemandPredictionViewState extends State<DemandPredictionView> {
  final _dependencies = BackendDependencies.create();
  List<Commodity> _commodities = const [];
  String? _selectedCommodityId;
  bool _loadingCommodities = true;
  bool _loading = false;
  String? _error;
  DemandPrediction? _prediction;

  @override
  void initState() {
    super.initState();
    _loadCommodities();
  }

  Future<void> _loadCommodities() async {
    final result = await _dependencies.commodityRepository.getCommodities();
    if (!mounted) return;
    setState(() {
      _loadingCommodities = false;
      switch (result) {
        case Success(data: final values):
          _commodities = values;
          _selectedCommodityId = values.isEmpty ? null : values.first.id;
          if (values.isEmpty) _error = 'Belum ada komoditas aktif.';
        case Failure(message: final message):
          _error = message;
      }
    });
  }

  Future<void> _predict() async {
    final commodityId = _selectedCommodityId;
    if (commodityId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _dependencies.aiRepository.predictDemand(
      commodityId: commodityId,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(data: final value):
          _prediction = value;
        case Failure(message: final message):
          _error = message;
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Prediksi Kebutuhan')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedCommodityId),
          initialValue: _selectedCommodityId,
          decoration: const InputDecoration(
            labelText: 'Pilih Komoditas',
            border: OutlineInputBorder(),
          ),
          items: _commodities
              .map(
                (commodity) => DropdownMenuItem(
                  value: commodity.id,
                  child: Text('${commodity.name} (${commodity.unit})'),
                ),
              )
              .toList(),
          onChanged: _loading || _loadingCommodities
              ? null
              : (value) {
                  setState(() {
                    _selectedCommodityId = value;
                    _prediction = null;
                    _error = null;
                  });
                },
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed:
              _loading || _loadingCommodities || _selectedCommodityId == null
              ? null
              : _predict,
          child: Text(
            _loadingCommodities
                ? 'Memuat komoditas...'
                : _loading
                ? 'Memproses...'
                : 'Prediksi Demand',
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        if (_prediction case final prediction?)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.commodityName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Text('Prediksi kebutuhan:'),
                    Text(
                      '${prediction.predictedQuantity.toStringAsFixed(2)} ${prediction.commodityUnit}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text('Periode: ${prediction.predictionPeriod}'),
                    Text(
                      'Histori digunakan: ${prediction.historyCount} minggu',
                    ),
                    Text(
                      'Demand terakhir: ${prediction.latestQuantity} ${prediction.commodityUnit}',
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_prediction case final prediction?)
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateDemandView(
                  initialCommodityId: prediction.commodityId,
                  initialQuantity: prediction.predictedQuantity,
                  forecastSource: 'AI',
                ),
              ),
            ),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Gunakan Prediksi'),
          ),
      ],
    ),
  );
}
