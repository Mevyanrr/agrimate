import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/database_tables.dart';
import '../../../../core/errors/backend_exception.dart';
import '../models/profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel?> getMine();
  Future<ProfileModel> create(ProfileModel profile);
  Future<ProfileModel> updateMine(ProfileModel profile);
}

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  const SupabaseProfileRemoteDataSource(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser?.id ??
      (throw const BackendException('Pengguna belum login.', code: 'unauthenticated'));

  @override
  Future<ProfileModel?> getMine() async {
    final row = await _client.from(DatabaseTables.profiles).select()
        .eq('id', _userId).maybeSingle();
    return row == null ? null : ProfileModel.fromJson(row);
  }

  @override
  Future<ProfileModel> create(ProfileModel profile) async {
    final row = await _client.from(DatabaseTables.profiles).insert({
      ...profile.toCreateJson(),
      'id': _userId,
    }).select().single();
    return ProfileModel.fromJson(row);
  }

  @override
  Future<ProfileModel> updateMine(ProfileModel profile) async {
    final row = await _client.from(DatabaseTables.profiles)
        .update(profile.toEditableJson()).eq('id', _userId).select().single();
    return ProfileModel.fromJson(row);
  }
}
