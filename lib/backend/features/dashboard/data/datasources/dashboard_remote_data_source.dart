import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_summary_model.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getSummary();
}

class SupabaseDashboardRemoteDataSource implements DashboardRemoteDataSource {
  const SupabaseDashboardRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<DashboardSummaryModel> getSummary() async {
    final result = await _client.rpc('get_dashboard_summary');
    return DashboardSummaryModel.fromJson(Map<String, dynamic>.from(result));
  }
}
