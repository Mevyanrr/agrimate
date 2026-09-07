class NormalizedAddress {
  const NormalizedAddress({
    required this.original,
    required this.province,
    required this.city,
    required this.district,
    required this.needsConfirmation,
    this.reason,
  });

  final String original;
  final String? province;
  final String? city;
  final String? district;
  final bool needsConfirmation;
  final String? reason;
}
