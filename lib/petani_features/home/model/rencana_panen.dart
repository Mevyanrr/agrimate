import 'package:agrimate/petani_features/home/model/home.dart';

class RencanaPanenDataModel {
  final List<HarvestPlanModel> plans;
 
  const RencanaPanenDataModel({required this.plans});
 
  bool get isEmpty => plans.isEmpty;
 
  factory RencanaPanenDataModel.fromJson(Map<String, dynamic> json) {
    final rawPlans = json['plans'] as List<dynamic>? ?? [];
    return RencanaPanenDataModel(
      plans: rawPlans
          .map((e) => HarvestPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}