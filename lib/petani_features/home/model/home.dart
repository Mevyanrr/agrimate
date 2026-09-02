class FarmerProfileModel {
  final String? photoUrl; 
  final String name;
  final String location;

  const FarmerProfileModel({
    this.photoUrl,
    required this.name,
    required this.location,
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      photoUrl: json['photo_url'] as String?,
      name: json['name'] as String? ?? '-',
      location: json['location'] as String? ?? '-',
    );
  }
}

class HomeSummaryModel {
  final int activePlans;
  final double totalAllocatedKg;
  final int completedTransactions;

  const HomeSummaryModel({
    required this.activePlans,
    required this.totalAllocatedKg,
    required this.completedTransactions,
  });

  factory HomeSummaryModel.fromJson(Map<String, dynamic> json) {
    return HomeSummaryModel(
      activePlans: json['active_plans'] as int? ?? 0,
      totalAllocatedKg: (json['total_allocated_kg'] as num?)?.toDouble() ?? 0,
      completedTransactions: json['completed_transactions'] as int? ?? 0,
    );
  }
}

class BuyerMatchModel {
  final int matchCount;

  const BuyerMatchModel({required this.matchCount});

  bool get hasMatch => matchCount > 0;

  factory BuyerMatchModel.fromJson(Map<String, dynamic> json) {
    return BuyerMatchModel(matchCount: json['match_count'] as int? ?? 0);
  }
}

class HarvestPlanModel {
  final String id;
  final String commodityName;
  final String commodityEmoji; 
  final String dateRangeLabel; 
  final double totalWeightKg;
  final double allocatedWeightKg;
  final bool hasMatch;

  const HarvestPlanModel({
    required this.id,
    required this.commodityName,
    required this.commodityEmoji,
    required this.dateRangeLabel,
    required this.totalWeightKg,
    required this.allocatedWeightKg,
    required this.hasMatch,
  });

  double get progress =>
      totalWeightKg == 0 ? 0 : (allocatedWeightKg / totalWeightKg).clamp(0, 1);

  factory HarvestPlanModel.fromJson(Map<String, dynamic> json) {
    return HarvestPlanModel(
      id: json['id'] as String,
      commodityName: json['commodity_name'] as String? ?? '-',
      commodityEmoji: json['commodity_emoji'] as String? ?? '🌾',
      dateRangeLabel: json['date_range_label'] as String? ?? '-',
      totalWeightKg: (json['total_weight_kg'] as num?)?.toDouble() ?? 0,
      allocatedWeightKg: (json['allocated_weight_kg'] as num?)?.toDouble() ?? 0,
      hasMatch: json['has_match'] as bool? ?? false,
    );
  }
}

class HomeDataModel {
  final FarmerProfileModel profile;
  final HomeSummaryModel summary;
  final BuyerMatchModel buyerMatch;
  final List<HarvestPlanModel> recentPlans;

  const HomeDataModel({
    required this.profile,
    required this.summary,
    required this.buyerMatch,
    required this.recentPlans,
  });
}