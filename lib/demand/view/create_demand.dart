import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:agrimate/backend/features/demand/domain/entities/demand_forecast.dart';
import 'package:flutter/material.dart';

class CreateDemandView extends StatefulWidget {
  const CreateDemandView({
    super.key,
    this.initialCommodityId,
    this.initialQuantity,
    this.forecastSource = 'MANUAL',
  });

  final String? initialCommodityId;
  final double? initialQuantity;
  final String forecastSource;

  @override
  State<CreateDemandView> createState() => _CreateDemandViewState();
}

class _CreateDemandViewState extends State<CreateDemandView> {
  final _dependencies = BackendDependencies.create();
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _address = TextEditingController();
  List<Commodity> _commodities = const [];
  String? _commodityId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _commodityId = widget.initialCommodityId;
    if (widget.initialQuantity != null) {
      _quantity.text = widget.initialQuantity!.toStringAsFixed(2);
    }
    _loadCommodities();
  }

  Future<void> _loadCommodities() async {
    final result = await _dependencies.commodityRepository.getCommodities();
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Success(data: final values):
          _commodities = values;
          if (_commodityId == null && values.isNotEmpty) {
            _commodityId = values.first.id;
          }
        case Failure(message: final message):
          _error = message;
      }
    });
  }

  Future<void> _pickDate({required bool start}) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: start
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
    );
    if (date != null) {
      setState(() => start ? _startDate = date : _endDate = date);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_commodityId == null || _startDate == null || _endDate == null) {
      setState(() => _error = 'Komoditas dan rentang tanggal wajib diisi.');
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      setState(
        () => _error = 'Tanggal akhir tidak boleh sebelum tanggal awal.',
      );
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await _dependencies.demandRepository.create(
      DemandForecast(
        commodityId: _commodityId!,
        quantity: double.parse(_quantity.text.replaceAll(',', '.')),
        neededStartDate: _startDate!,
        neededEndDate: _endDate!,
        deliveryAddress: _address.text.trim(),
        forecastSource: widget.forecastSource,
      ),
    );
    if (!mounted) return;
    switch (result) {
      case Success():
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home-pembeli',
          (_) => false,
        );
      case Failure(message: final message):
        setState(() {
          _submitting = false;
          _error = message;
        });
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tambah Kebutuhan')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _commodityId,
                  decoration: const InputDecoration(
                    labelText: 'Komoditas',
                    border: OutlineInputBorder(),
                  ),
                  items: _commodities
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _commodityId = value),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Jumlah (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (double.tryParse((value ?? '').replaceAll(',', '.')) ??
                              0) >
                          0
                      ? null
                      : 'Jumlah harus lebih dari 0',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(start: true),
                        child: Text(_dateLabel(_startDate, 'Tanggal awal')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickDate(start: false),
                        child: Text(_dateLabel(_endDate, 'Tanggal akhir')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _address,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Alamat pengiriman',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'Alamat wajib diisi'
                      : null,
                ),
                const SizedBox(height: 10),
                Text('Sumber forecast: ${widget.forecastSource}'),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(
                    _submitting ? 'Menyimpan...' : 'Simpan dan Cari Match',
                  ),
                ),
              ],
            ),
          ),
  );

  String _dateLabel(DateTime? date, String fallback) =>
      date == null ? fallback : '${date.day}/${date.month}/${date.year}';
}
