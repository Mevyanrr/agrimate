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

class KomoditasModel {
  final String id;
  final String name;
  final String emoji;

  const KomoditasModel({
    required this.id,
    required this.name,
    required this.emoji,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is KomoditasModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
class KomoditasData {
  static const List<KomoditasModel> list = [
    KomoditasModel(id: 'tomat', name: 'Tomat', emoji: '🍅'),
    KomoditasModel(id: 'sawi', name: 'Sawi', emoji: '🥬'),
    KomoditasModel(id: 'cabai_rawit', name: 'Cabai Rawit', emoji: '🌶️'),
    KomoditasModel(id: 'bawang_bombay', name: 'Bawang Bombay', emoji: '🧅'),
    KomoditasModel(id: 'jagung', name: 'Jagung', emoji: '🌽'),
    KomoditasModel(id: 'kentang', name: 'Kentang', emoji: '🥔'),
    KomoditasModel(id: 'bayam', name: 'Bayam', emoji: '🍃'),
    KomoditasModel(id: 'wortel', name: 'Wortel', emoji: '🥕'),
    KomoditasModel(id: 'cabai_merah', name: 'Cabai Merah', emoji: '🌶️'),
    KomoditasModel(id: 'kol', name: 'Kol', emoji: '🥦'),
    KomoditasModel(id: 'buncis', name: 'Buncis', emoji: '🫛'),
    KomoditasModel(id: 'bawang_merah', name: 'Bawang Merah', emoji: '🧅'),
  ];
}

/// Representasi 1 "Rencana Panen" hasil dari flow 4 halaman.
class RencanaModel {
  final KomoditasModel? komoditas;
  final int kuantitas; // dalam kg
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;

  const RencanaModel({
    this.komoditas,
    this.kuantitas = 0,
    this.tanggalMulai,
    this.tanggalSelesai,
  });

  /// Estimasi durasi panen dalam hari (selisih tanggal selesai - mulai).
  int get durasiHari {
    if (tanggalMulai == null || tanggalSelesai == null) return 0;
    return tanggalSelesai!.difference(tanggalMulai!).inDays;
  }

  RencanaModel copyWith({
    KomoditasModel? komoditas,
    int? kuantitas,
    DateTime? tanggalMulai,
    DateTime? tanggalSelesai,
  }) {
    return RencanaModel(
      komoditas: komoditas ?? this.komoditas,
      kuantitas: kuantitas ?? this.kuantitas,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
    );
  }

  /// Payload siap kirim ke backend.
  Map<String, dynamic> toJson() => {
        'komoditas_id': komoditas?.id,
        'komoditas_name': komoditas?.name,
        'kuantitas_kg': kuantitas,
        'tanggal_mulai': tanggalMulai?.toIso8601String(),
        'tanggal_selesai': tanggalSelesai?.toIso8601String(),
        'estimasi_durasi_hari': durasiHari,
      };
}