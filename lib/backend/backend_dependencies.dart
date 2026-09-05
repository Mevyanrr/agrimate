import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/ai/data/repositories/ai_repository_impl.dart';
import 'features/ai/domain/repositories/ai_repository.dart';
import 'features/commodities/data/datasources/commodity_remote_data_source.dart';
import 'features/commodities/data/repositories/commodity_repository_impl.dart';
import 'features/commodities/domain/repositories/commodity_repository.dart';
import 'features/demand/data/datasources/demand_remote_data_source.dart';
import 'features/demand/data/repositories/demand_repository_impl.dart';
import 'features/demand/domain/repositories/demand_repository.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/identity_verification/data/datasources/identity_verification_remote_data_source.dart';
import 'features/identity_verification/data/repositories/identity_verification_repository_impl.dart';
import 'features/identity_verification/domain/repositories/identity_verification_repository.dart';
import 'features/matches/data/datasources/match_remote_data_source.dart';
import 'features/matches/data/repositories/match_repository_impl.dart';
import 'features/matches/domain/repositories/match_repository.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/supply/data/datasources/supply_remote_data_source.dart';
import 'features/supply/data/repositories/supply_repository_impl.dart';
import 'features/supply/domain/repositories/supply_repository.dart';
import 'features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';

/// Composition root backend. Semua dependency feature dirangkai di sini.
class BackendDependencies {
  BackendDependencies._(SupabaseClient client)
    : authRepository = SupabaseAuthRepository(client),
      aiRepository = AiRepositoryImpl(client),
      commodityRepository = CommodityRepositoryImpl(
        SupabaseCommodityRemoteDataSource(client),
      ),
      supplyRepository = SupplyRepositoryImpl(
        SupabaseSupplyRemoteDataSource(client),
      ),
      demandRepository = DemandRepositoryImpl(
        SupabaseDemandRemoteDataSource(client),
      ),
      dashboardRepository = DashboardRepositoryImpl(
        SupabaseDashboardRemoteDataSource(client),
      ),
      profileRepository = ProfileRepositoryImpl(
        SupabaseProfileRemoteDataSource(client),
      ),
      identityVerificationRepository = IdentityVerificationRepositoryImpl(
        SupabaseIdentityVerificationRemoteDataSource(client),
      ),
      matches = MatchRepositoryImpl(SupabaseMatchRemoteDataSource(client)),
      transactions = TransactionRepositoryImpl(
        SupabaseTransactionRemoteDataSource(client),
      ),
      notifications = NotificationRepositoryImpl(
        SupabaseNotificationRemoteDataSource(client),
      );

  factory BackendDependencies.create() {
    return BackendDependencies._(Supabase.instance.client);
  }

  final AuthRepository authRepository;
  final AiRepository aiRepository;
  final CommodityRepository commodityRepository;
  final SupplyRepository supplyRepository;
  final DemandRepository demandRepository;
  final DashboardRepository dashboardRepository;
  final ProfileRepository profileRepository;
  final IdentityVerificationRepository identityVerificationRepository;
  final MatchRepository matches;
  final TransactionRepository transactions;
  final NotificationRepository notifications;
}
