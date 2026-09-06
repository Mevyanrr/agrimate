class RencanaSummaryModel {
  final String komoditasName;
  final String komoditasEmoji;
  final int kuantitasKg;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final String lokasiKirim;

  const RencanaSummaryModel({
    required this.komoditasName,
    required this.komoditasEmoji,
    required this.kuantitasKg,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.lokasiKirim,
  });

  static const List<String> _bulanPendek = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  String _pad2(int n) => n.toString().padLeft(2, '0');

  String get periodeLabel {
    if (tanggalMulai.month == tanggalSelesai.month && tanggalMulai.year == tanggalSelesai.year) {
      return '${tanggalMulai.day}-${tanggalSelesai.day} ${_bulanPendek[tanggalSelesai.month - 1]} ${tanggalSelesai.year}';
    }
    return '${tanggalMulai.day} ${_bulanPendek[tanggalMulai.month - 1]} - '
        '${tanggalSelesai.day} ${_bulanPendek[tanggalSelesai.month - 1]} ${tanggalSelesai.year}';
  }

  String get rangeIsoLabel {
    final mulai = '${tanggalMulai.year}-${_pad2(tanggalMulai.month)}-${_pad2(tanggalMulai.day)}';
    final selesai = '${tanggalSelesai.year}-${_pad2(tanggalSelesai.month)}-${_pad2(tanggalSelesai.day)}';
    return '$mulai s/d $selesai';
  }
}