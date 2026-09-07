import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/errors/backend_exception.dart';
import '../../domain/entities/normalized_address.dart';

class AddressAiService {
  AddressAiService({http.Client? client}) : _client = client ?? http.Client();

  static const _endpoint =
      'https://agrimate-ai-76mm.onrender.com/parse-address';
  final http.Client _client;

  Future<NormalizedAddress> parse(String address) async {
    final normalizedInput = address.trim();
    if (normalizedInput.isEmpty) {
      throw const BackendException(
        'Alamat wajib diisi.',
        code: 'empty_address',
      );
    }

    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'address': normalizedInput}),
          )
          .timeout(const Duration(seconds: 90));
      if (response.statusCode != 200) {
        throw BackendException(
          'Normalisasi alamat gagal (HTTP ${response.statusCode}).',
          code: 'address_http_${response.statusCode}',
        );
      }
      final json = jsonDecode(response.body);
      if (json is! Map) {
        throw const BackendException(
          'Respons normalisasi alamat tidak valid.',
          code: 'invalid_address_response',
        );
      }
      final data = Map<String, dynamic>.from(json);
      return NormalizedAddress(
        original: data['address_original']?.toString() ?? normalizedInput,
        province: _nullableText(data['province']),
        city: _nullableText(data['city']),
        district: _nullableText(data['district']),
        needsConfirmation: data['needs_confirmation'] as bool? ?? true,
        reason: _nullableText(data['reason']),
      );
    } on TimeoutException {
      throw const BackendException(
        'Normalisasi alamat terlalu lama. Coba lagi.',
        code: 'address_timeout',
      );
    } on FormatException {
      throw const BackendException(
        'Respons normalisasi alamat tidak valid.',
        code: 'invalid_address_response',
      );
    }
  }

  static String? _nullableText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
