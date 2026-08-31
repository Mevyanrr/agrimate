import 'package:agrimate/role_selection/view/role.dart';
import 'package:agrimate/role_selection/viewmodel/role_vm.dart';
import 'package:agrimate/splash_onboarding/view/onboarding.dart';
import 'package:agrimate/splash_onboarding/viewmodel/onboarding_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:agrimate/splash_onboarding/view/splash.dart';
import 'package:agrimate/splash_onboarding/view/splash_next.dart';
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
         ChangeNotifierProvider<OnboardingViewModel>(create: (_) => OnboardingViewModel()),
         ChangeNotifierProvider<RoleViewModel>(create: (_) => RoleViewModel()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 844), 
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
            },
          );
        },
      ),
    );
  }
}