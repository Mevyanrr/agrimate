class DashboardSummary {
  const DashboardSummary({
    required this.role,
    required this.activeForecasts,
    required this.potentialMatches,
    required this.transactions,
    required this.transactionValue,
  });

  final String role;
  final int activeForecasts;
  final int potentialMatches;
  final int transactions;
  final double transactionValue;
}
