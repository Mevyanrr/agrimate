import 'package:agrimate/auth/model/otp.dart';
import 'package:agrimate/auth/view/daftar_akun.dart';
import 'package:agrimate/auth/view/masuk.dart';
import 'package:agrimate/auth/view/otp_verif.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/role_selection/view/role.dart';
import 'package:agrimate/role_selection/viewmodel/role_vm.dart';
import 'package:agrimate/splash_onboarding/view/onboarding.dart';
import 'package:agrimate/splash_onboarding/view/splash.dart';
import 'package:agrimate/splash_onboarding/view/splash_next.dart';
import 'package:agrimate/splash_onboarding/viewmodel/onboarding_vm.dart';
import 'package:agrimate/splash_onboarding/viewmodel/splash_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('SUPABASE_ANON_KEY'),
  );
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
                final role = ModalRoute.of(context)!.settings.arguments as UserRole;
                return LoginView(role: role);
              },
              '/register': (context) {
                final role = ModalRoute.of(context)!.settings.arguments as UserRole;
                return RegisterView(role: role);
              },
              '/otp-verification': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
                return OtpVerificationView(
                  role: args['role'] as UserRole,
                  phoneNumber: args['phoneNumber'] as String,
                  method: args['method'] as OtpMethod,
                );
              },
            },
          );
        },
      ),
    );
  }
}
