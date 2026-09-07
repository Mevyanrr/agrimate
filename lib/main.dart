import 'package:agrimate/auth/model/otp.dart';
import 'package:agrimate/auth/view/daftar_akun.dart';
import 'package:agrimate/auth/view/masuk.dart';
import 'package:agrimate/auth/view/otp_verif.dart';
import 'package:agrimate/petani_features/home/view/home_page.dart';
import 'package:agrimate/petani_features/lengkapi_profil/view/lengkapi_profil.dart';
import 'package:agrimate/petani_features/pasar/view/pasar.dart';
import 'package:agrimate/petani_features/pasar/viewmodel/pasar_vm.dart';
import 'package:agrimate/petani_features/rencana_panen/view/rencana_panen.dart';
import 'package:agrimate/petani_features/rencana_panen/view/tambah_rencana.dart';
import 'package:agrimate/profil/view/profil.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/role_selection/view/role.dart';
import 'package:agrimate/role_selection/viewmodel/role_vm.dart';
import 'package:agrimate/splash_onboarding/view/onboarding.dart';
import 'package:agrimate/splash_onboarding/view/splash_next.dart';
import 'package:agrimate/splash_onboarding/viewmodel/onboarding_vm.dart';
import 'package:agrimate/transaksi/model/transaction.dart';
import 'package:agrimate/transaksi/view/transaction_detail_view.dart';
import 'package:agrimate/transaksi/view/transaction_list_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agrimate/splash_onboarding/view/splash.dart';
import 'package:agrimate/splash_onboarding/viewmodel/splash_vm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SplashViewModel>(
          create: (_) => SplashViewModel(),
        ),
        ChangeNotifierProvider<OnboardingViewModel>(
          create: (_) => OnboardingViewModel(),
        ),
        ChangeNotifierProvider<RoleViewModel>(create: (_) => RoleViewModel()),
        ChangeNotifierProvider<PasarViewModel>(create: (_) => PasarViewModel()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'MyApp',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true),
            initialRoute: '/splash1',
            routes: {
              '/splash1': (context) => const SplashPage1(),
              '/splash2': (context) => const SplashPage2(),
              '/onboarding': (context) => const OnboardingView(),
              '/role-selection': (context) => const RoleView(),
              '/login': (context) {
                final role =
                    ModalRoute.of(context)?.settings.arguments as UserRole? ??
                    UserRole.petani;
                return LoginView(role: role);
              },
              '/register': (context) {
                final role =
                    ModalRoute.of(context)?.settings.arguments as UserRole? ??
                    UserRole.petani;
                return RegisterView(role: role);
              },
              '/otp-verification': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>;
                return OtpVerificationView(
                  role: args['role'] as UserRole,
                  phoneNumber: args['phoneNumber'] as String,
                  method: args['method'] as OtpMethod,
                );
              },
              '/home-petani': (context) => const HomeView(),
              '/rencana-panen': (context) => const RencanaPanenView(),
              '/tambah-rencana': (context) => const RencanaFlowPage(),
              '/pasar': (context) => const PasarView(),
              '/lengkapi-profil': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final UserRole role =
                    args?['role'] as UserRole? ??
                    UserRole.petani; 

                return LengkapiProfilView(role: role);
              },
              '/profil': (context) {
                final role =
                    ModalRoute.of(context)?.settings.arguments as UserRole? ??
                    UserRole.petani;
                return ProfileView(role: role);
              },
              '/transaksi': (context) {
                final role =
                    ModalRoute.of(context)!.settings.arguments as UserRole? ??
                    UserRole.petani;
                return TransactionListView(role: role);
              },
              '/transaction-detail': (context) {
                final args =
                    ModalRoute.of(context)!.settings.arguments
                        as Map<String, dynamic>;
                return TransactionDetailView(
                  role: args['role'] as UserRole,
                  transaction: args['transaction'] as TransactionModel,
                );
              },
            },
          );
        },
      ),
    );
  }
}
