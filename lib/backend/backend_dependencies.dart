import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/commodities/data/datasources/commodity_remote_data_source.dart';
import 'features/commodities/data/repositories/commodity_repository_impl.dart';
import 'features/commodities/domain/repositories/commodity_repository.dart';
import 'features/demand/data/datasources/demand_remote_data_source.dart';
import 'features/demand/data/repositories/demand_repository_impl.dart';
import 'features/demand/domain/repositories/demand_repository.dart';
import 'features/matches/data/datasources/match_remote_data_source.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';
import 'features/supply/data/datasources/supply_remote_data_source.dart';
import 'features/supply/data/repositories/supply_repository_impl.dart';
import 'features/supply/domain/repositories/supply_repository.dart';
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';

/// Composition root backend. Semua dependency feature dirangkai di sini.
class BackendDependencies {
  BackendDependencies._(SupabaseClient client)
    : commodityRepository = CommodityRepositoryImpl(SupabaseCommodityRemoteDataSource(client)),
      supplyRepository = SupplyRepositoryImpl(SupabaseSupplyRemoteDataSource(client)),
      demandRepository = DemandRepositoryImpl(SupabaseDemandRemoteDataSource(client)),
      matches = SupabaseMatchRemoteDataSource(client),
      transactions = SupabaseTransactionRemoteDataSource(client),
      notifications = SupabaseNotificationRemoteDataSource(client);

  factory BackendDependencies.create() {
    return BackendDependencies._(Supabase.instance.client);
  }

  final CommodityRepository commodityRepository;
  final SupplyRepository supplyRepository;
  final DemandRepository demandRepository;
  final MatchRemoteDataSource matches;
  final TransactionRemoteDataSource transactions;
  final NotificationRemoteDataSource notifications;

  // TODO: Tambahkan ProfileRepository setelah feature profile selesai dirapikan.
}
