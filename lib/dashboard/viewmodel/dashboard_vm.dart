import 'package:agrimate/backend/backend_dependencies.dart';
import 'package:agrimate/backend/core/result/result.dart';
import 'package:agrimate/backend/features/commodities/domain/entities/commodity.dart';
import 'package:agrimate/backend/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:agrimate/backend/features/matches/domain/entities/market_match.dart';
import 'package:agrimate/backend/features/profile/domain/entities/profile_entity.dart';
import 'package:flutter/material.dart';

class DashboardViewModel extends ChangeNotifier {
  final _dependencies = BackendDependencies.create();

  DashboardSummary? summary;
  ProfileEntity? profile;
  Commodity? referenceCommodity;
  MarketMatch? latestMatch;
  String? errorMessage;
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final results = await Future.wait([
      _dependencies.dashboardRepository.getSummary(),
      _dependencies.profileRepository.getMine(),
      _dependencies.commodityRepository.getCommodities(),
      _dependencies.matches.getMine(),
    ]);
    final summaryResult = results[0] as Result<DashboardSummary>;
    final profileResult = results[1] as Result<ProfileEntity?>;
    final commodityResult = results[2] as Result<List<Commodity>>;
    final matchResult = results[3] as Result<List<MarketMatch>>;

    switch (summaryResult) {
      case Success(data: final value):
        summary = value;
      case Failure(message: final message):
        errorMessage = message;
    }
    if (profileResult case Success(data: final value)) profile = value;
    if (commodityResult case Success(data: final values)) {
      referenceCommodity = values.isEmpty ? null : values.first;
    }
    if (matchResult case Success(data: final values)) {
      latestMatch = values.isEmpty ? null : values.first;
    }

    isLoading = false;
    notifyListeners();
  }
}
