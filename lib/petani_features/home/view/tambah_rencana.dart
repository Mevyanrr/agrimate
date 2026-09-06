import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/home/viewmodel/rencana_panen_vm.dart';
import 'package:agrimate/petani_features/widget/appbar.dart';
import 'package:agrimate/petani_features/widget/rencana_lanjutbottom.dart';
import 'package:agrimate/petani_features/widget/rencana_page1.dart';
import 'package:agrimate/petani_features/widget/rencana_page2.dart';
import 'package:agrimate/petani_features/widget/rencana_page3.dart';
import 'package:agrimate/petani_features/widget/rencana_page4.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RencanaFlowPage extends StatelessWidget {
  const RencanaFlowPage({super.key});

  static const routeName = '/rencana-baru';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RencanaViewModel(),
      child: const _RencanaFlowBody(),
    );
  }
}

class _RencanaFlowBody extends StatelessWidget {
  const _RencanaFlowBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RencanaViewModel>();
    final isLastStep = vm.currentStep == RencanaViewModel.totalSteps - 1;

    return Scaffold(
      backgroundColor: AppColors.scaffoldGrey,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            HomeAppBar(
              onNotificationTap: () => vm.onNotificationPressed(context),
              onSettingsTap: () => vm.onSettingsPressed(context),
            ),
            Expanded(
              child: PageView(
                controller: vm.pageController,
              
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  Page1KomoditasView(),
                  Page2KuantitasView(),
                  Page3TanggalView(),
                  Page4KonfirmasiView(),
                ],
              ),
            ),
            RencanaBottomButton(
              label: isLastStep ? 'Sudah Benar? Cari Pembeli' : 'Lanjut',
              enabled: isLastStep ? !vm.isSubmitting : vm.isCurrentStepValid,
              isLoading: vm.isSubmitting,
              onPressed: () async {
                if (!isLastStep) {
                  vm.nextPage();
                  return;
                }
                final success = await vm.submitRencana();
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rencana berhasil diajukan!')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal mengajukan rencana, coba lagi.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}