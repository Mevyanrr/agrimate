/// Nama tabel/view Supabase dikumpulkan di sini agar tidak tersebar.
abstract final class DatabaseTables {
  // TODO: Ganti dengan nama tabel asli di Supabase.
  static const String profileTable= 'profiles';
  static const String supplyForecastTable= 'supply_forecast';
  static const String transactionTable= 'transactions';
  static const String notificationTable= 'notifications';
  static const String matchesTable= 'matches';
  static const String demandForecastTable= 'demand_forecasts';
  static const String commodityPriceTable= 'commodity_prices';
  static const String commodityTable= 'commodities';
  static const String feeTables= 'app_settings';
  static const String identityVerifications = 'identity_verifications';
}

abstract final class StorageBuckets {
  static const String identityDocuments = 'identity-documents';
}