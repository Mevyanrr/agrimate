class MarketTransaction {
  const MarketTransaction({required this.id, required this.data});
  final String id;

  /// TODO: Ganti dengan field typed setelah schema transactions sudah final.
  final Map<String, dynamic> data;
}
