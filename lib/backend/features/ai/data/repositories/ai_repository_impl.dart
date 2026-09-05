import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/demand_prediction.dart';
import '../../domain/repositories/ai_repository.dart';
import '../models/demand_prediction_model.dart';

class AiRepositoryImpl implements AiRepository {
  AiRepositoryImpl(this._supabase, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'https://agrimate-ai-76mm.onrender.com';
  final SupabaseClient _supabase;
  final http.Client _httpClient;

  @override
  Future<Result<DemandPrediction>> predictDemand({
    required String commodityId,
  }) async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      return const Failure('User belum login.', code: 'unauthenticated');
    }

    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl/predict-demand'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.accessToken}',
            },
            body: jsonEncode({'commodity_id': commodityId}),
          )
          .timeout(const Duration(seconds: 90));

      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (response.statusCode == 200 && decoded is Map) {
        return Success(
          DemandPredictionModel.fromJson(Map<String, dynamic>.from(decoded)),
        );
      }
      final detail = decoded is Map ? decoded['detail']?.toString() : null;
      return Failure(
        detail ?? _messageForStatus(response.statusCode),
        code: 'http_${response.statusCode}',
      );
    } on TimeoutException {
      return const Failure(
        'Server prediksi membutuhkan waktu terlalu lama. Coba lagi.',
        code: 'timeout',
      );
    } on FormatException {
      return const Failure(
        'Respons server prediksi tidak valid.',
        code: 'invalid_response',
      );
    } catch (error) {
      return Failure('Tidak dapat menghubungi server prediksi: $error');
    }
  }

  String _messageForStatus(int statusCode) => switch (statusCode) {
    400 => 'Data historis belum cukup.',
    401 => 'Session login tidak valid atau kedaluwarsa.',
    403 => 'Fitur prediksi hanya tersedia untuk buyer.',
    _ => 'Prediksi gagal (HTTP $statusCode).',
  };
}
