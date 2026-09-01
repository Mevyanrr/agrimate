import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/commodities/data/datasources/commodity_remote_data_source.dart';
import 'features/commodities/data/repositories/commodity_repository_impl.dart';
import 'features/commodities/domain/repositories/commodity_repository.dart';
import 'features/demand/data/datasources/demand_remote_data_source.dart';
import 'features/demand/data/repositories/demand_repository_impl.dart';
import 'features/demand/domain/repositories/demand_repository.dart';
import 'features/identity_verification/data/datasources/identity_verification_remote_data_source.dart';
import 'features/identity_verification/data/repositories/identity_verification_repository_impl.dart';
import 'features/identity_verification/domain/repositories/identity_verification_repository.dart';
import 'features/matches/data/datasources/match_remote_data_source.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/supply/data/datasources/supply_remote_data_source.dart';
import 'features/supply/data/repositories/supply_repository_impl.dart';
import 'features/supply/domain/repositories/supply_repository.dart';
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';

/// Composition root backend. Semua dependency feature dirangkai di sini.
class BackendDependencies {
  BackendDependencies._(SupabaseClient client)
    : authRepository = SupabaseAuthRepository(client),
      commodityRepository = CommodityRepositoryImpl(
        SupabaseCommodityRemoteDataSource(client),
      ),
      supplyRepository = SupplyRepositoryImpl(
        SupabaseSupplyRemoteDataSource(client),
      ),
      demandRepository = DemandRepositoryImpl(
        SupabaseDemandRemoteDataSource(client),
      ),
      profileRepository = ProfileRepositoryImpl(
        SupabaseProfileRemoteDataSource(client),
      ),
      identityVerificationRepository = IdentityVerificationRepositoryImpl(
        SupabaseIdentityVerificationRemoteDataSource(client),
      ),
      matches = SupabaseMatchRemoteDataSource(client),
      transactions = SupabaseTransactionRemoteDataSource(client),
      notifications = SupabaseNotificationRemoteDataSource(client);

  factory BackendDependencies.create() {
    return BackendDependencies._(Supabase.instance.client);
  }

  final AuthRepository authRepository;
  final CommodityRepository commodityRepository;
  final SupplyRepository supplyRepository;
  final DemandRepository demandRepository;
  final ProfileRepository profileRepository;
  final IdentityVerificationRepository identityVerificationRepository;
  final MatchRemoteDataSource matches;
  final TransactionRemoteDataSource transactions;
  final NotificationRemoteDataSource notifications;
}
