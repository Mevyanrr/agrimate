import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/rencana_summary_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/view/rencana_success_page.dart';
import 'package:agrimate/petani_features/rencana_panen/viewmodel/rencana_panen_vm.dart';
import 'package:agrimate/core/widget/appbar.dart';
import 'package:agrimate/petani_features/widget/rencana_header.dart';
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
        child: Column(
          children: [
             HomeAppBar(
  roleLabel: 'Petani',
  accentColor: AppColors.greenprimary,
  onNotificationTap: () => vm.onNotificationPressed(context),
  onSettingsTap: () => vm.onSettingsPressed(context),
),
            RencanaHeader(
              currentStep: vm.currentStep,
              onBack: () {
                if (vm.currentStep == 0) {
                  Navigator.of(context).pop();
                } else {
                  vm.previousPage();
                }
              },
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => RencanaSuccessPage(
                        rencana: RencanaSummaryModel(
                          komoditasName: vm.selectedKomoditas!.name,
                          komoditasEmoji: vm.selectedKomoditas!.emoji,
                          kuantitasKg: vm.kuantitas.toInt(),
                          tanggalMulai: vm.tanggalMulai!,
                          tanggalSelesai: vm.tanggalSelesai!,
                          lokasiKirim: 'Gudang Brebes', //DUMMY
                        ),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal mengajukan rencana, coba lagi.'),
                    ),
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
