enum BuyerResponseStatus { pending, accepted, rejected }

class MatchingBuyerModel {
  final String id;
  final String name;
  final String type; 
  final String location;
  final int matchPercentage; 
  final int alokasiKg;
  final int hargaPerKg;
  final int estimasiRp;
  final BuyerResponseStatus status;

  const MatchingBuyerModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.matchPercentage,
    required this.alokasiKg,
    required this.hargaPerKg,
    required this.estimasiRp,
    this.status = BuyerResponseStatus.pending,
  });

  MatchingBuyerModel copyWith({BuyerResponseStatus? status}) {
    return MatchingBuyerModel(
      id: id,
      name: name,
      type: type,
      location: location,
      matchPercentage: matchPercentage,
      alokasiKg: alokasiKg,
      hargaPerKg: hargaPerKg,
      estimasiRp: estimasiRp,
      status: status ?? this.status,
    );
  }
}