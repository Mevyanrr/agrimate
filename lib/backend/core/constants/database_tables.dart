/// Nama tabel/view Supabase dikumpulkan di sini agar tidak tersebar.
abstract final class DatabaseTables {
  static const String profiles = 'profiles';
  static const String commodities = 'commodities';
  static const String commodityPrices = 'commodity_prices';
  static const String supplyForecasts = 'supply_forecasts';
  static const String demandForecasts = 'demand_forecasts';
  static const String matches = 'matches';
  static const String transactions = 'transactions';
  static const String notifications = 'notifications';
  static const String identityVerifications = 'identity_verifications';
  static const String feeTables = 'app_settings';

  // Alias untuk kode yang masih memakai penamaan lama.
  static const String profileTable = profiles;
  static const String supplyForecastTable = supplyForecasts;
  static const String transactionTable = transactions;
  static const String notificationTable = notifications;
  static const String matchesTable = matches;
  static const String demandForecastTable = demandForecasts;
  static const String commodityPriceTable = commodityPrices;
  static const String commodityTable = commodities;
}

abstract final class StorageBuckets {
  static const String identityDocuments = 'identity-documents';
}
