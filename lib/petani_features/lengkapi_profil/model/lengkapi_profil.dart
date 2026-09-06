import 'dart:io';

class LengkapiProfilPayload {
  final String namaLengkap;
  final String nomorWhatsapp;
  final double? luasLahanHektar;
  final String alamatLahan;
  final String nikKtp;
  final File? fotoLahan;
  final File? fotoKtp;

  const LengkapiProfilPayload({
    required this.namaLengkap,
    required this.nomorWhatsapp,
    this.luasLahanHektar,
    required this.alamatLahan,
    required this.nikKtp,
    this.fotoLahan,
    this.fotoKtp,
  });

  Map<String, dynamic> toJson() => {
        'nama_lengkap': namaLengkap,
        'nomor_whatsapp': nomorWhatsapp,
        'luas_lahan_hektar': luasLahanHektar,
        'alamat_lahan': alamatLahan,
        'nik_ktp': nikKtp,
      };
}