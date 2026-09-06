import 'matching_buyer_model.dart';

class MatchingResultModel {
  final String komoditasName;
  final String komoditasEmoji;
  final int totalKg;
  final int terjualKg;
  final List<MatchingBuyerModel> buyers;

  const MatchingResultModel({
    required this.komoditasName,
    required this.komoditasEmoji,
    required this.totalKg,
    required this.terjualKg,
    required this.buyers,
  });

  int get matchCount => buyers.length;

  double get allocatedPercentage => totalKg == 0 ? 0 : (terjualKg / totalKg).clamp(0, 1);

  MatchingResultModel copyWith({int? terjualKg, List<MatchingBuyerModel>? buyers}) {
    return MatchingResultModel(
      komoditasName: komoditasName,
      komoditasEmoji: komoditasEmoji,
      totalKg: totalKg,
      terjualKg: terjualKg ?? this.terjualKg,
      buyers: buyers ?? this.buyers,
    );
  }
}