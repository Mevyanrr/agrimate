import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/database_tables.dart';
import '../models/market_transaction_model.dart';

abstract interface class TransactionRemoteDataSource {
  Future<List<MarketTransactionModel>> getMine();
  Future<MarketTransactionModel?> getByMatchId(String matchId);
  Future<void> complete(String transactionId);
  Future<void> submitRating({
    required String transactionId,
    required int rating,
    String? comment,
  });
}

class SupabaseTransactionRemoteDataSource
    implements TransactionRemoteDataSource {
  const SupabaseTransactionRemoteDataSource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<MarketTransactionModel>> getMine() async {
    // Transaction tetap read-only; hanya tabel rating yang menerima insert.
    final rows = await _client
        .from(DatabaseTables.transactions)
        .select('''
      *,
      commodity:commodity_id (*),
      ratings:transaction_ratings (rating, reviewer_id)
        ''')
        .order('created_at', ascending: false);
    final counterpartyIds = rows
        .map((row) {
          final farmerId = row['farmer_id']?.toString();
          final buyerId = row['buyer_id']?.toString();
          return _userId == farmerId ? buyerId : farmerId;
        })
        .whereType<String>()
        .toSet()
        .toList();
    final profileById = <String, Map<String, dynamic>>{};
    if (counterpartyIds.isNotEmpty) {
      final profiles = await _client
          .from(DatabaseTables.profiles)
          .select('id, full_name, phone, address')
          .inFilter('id', counterpartyIds);
      for (final profile in profiles) {
        profileById[profile['id'].toString()] = Map<String, dynamic>.from(
          profile,
        );
      }
    }
    return rows.map((row) {
      final data = Map<String, dynamic>.from(row);
      final farmerId = data['farmer_id']?.toString();
      final buyerId = data['buyer_id']?.toString();
      final counterpartyId = _userId == farmerId ? buyerId : farmerId;
      final counterparty = profileById[counterpartyId];
      final phone = counterparty?['phone']?.toString();
      data['counterparty_label'] =
          counterparty?['full_name']?.toString() ?? 'Profil tidak tersedia';
      data['phone_number'] = phone;
      data['whatsapp_number'] = phone;
      data['delivery_address'] = counterparty?['address']?.toString();
      final ratings = data['ratings'];
      if (ratings is List) {
        for (final item in ratings) {
          if (item is Map && item['reviewer_id'] == _userId) {
            data['rating_given'] = item['rating'];
            break;
          }
        }
      }
      return MarketTransactionModel.fromJson(data);
    }).toList();
  }

  @override
  Future<MarketTransactionModel?> getByMatchId(String matchId) async {
    final row = await _client
        .from(DatabaseTables.transactions)
        .select('''
      *,
      commodity:commodity_id (*)
    ''')
        .eq('match_id', matchId)
        .maybeSingle();
    return row == null ? null : MarketTransactionModel.fromJson(row);
  }

  @override
  Future<void> complete(String transactionId) => _client.rpc(
    'complete_transaction_after_contact',
    params: {'p_transaction_id': transactionId},
  );

  String get _userId =>
      _client.auth.currentUser?.id ??
      (throw const AuthException('Pengguna belum login.'));

  @override
  Future<void> submitRating({
    required String transactionId,
    required int rating,
    String? comment,
  }) async {
    final transaction = await _client
        .from(DatabaseTables.transactions)
        .select('farmer_id, buyer_id, status')
        .eq('id', transactionId)
        .single();

    final userId = _userId;
    final farmerId = transaction['farmer_id']?.toString();
    final buyerId = transaction['buyer_id']?.toString();
    final reviewedUserId = switch (userId) {
      final id when id == farmerId => buyerId,
      final id when id == buyerId => farmerId,
      _ => null,
    };
    if (reviewedUserId == null) {
      throw const AuthException('Kamu bukan bagian dari transaksi ini.');
    }

    final normalizedComment = comment?.trim();
    await _client.from(DatabaseTables.transactionRatings).insert({
      'transaction_id': transactionId,
      'reviewer_id': userId,
      'reviewed_user_id': reviewedUserId,
      'rating': rating,
      'comment': normalizedComment == null || normalizedComment.isEmpty
          ? null
          : normalizedComment,
    });
  }
}
