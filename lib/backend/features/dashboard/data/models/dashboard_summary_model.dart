import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.role,
    required super.activeForecasts,
    required super.potentialMatches,
    required super.transactions,
    required super.transactionValue,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) =>
      DashboardSummaryModel(
        role: json['role'] as String,
        activeForecasts: (json['active_forecasts'] as num).toInt(),
        potentialMatches: (json['potential_matches'] as num).toInt(),
        transactions: (json['transactions'] as num).toInt(),
        transactionValue: (json['transaction_value'] as num).toDouble(),
      );
}
