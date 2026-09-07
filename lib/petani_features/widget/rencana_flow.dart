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
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RencanaKebutuhanFlowPage extends StatelessWidget {
  final UserRole role;

  const RencanaKebutuhanFlowPage({super.key, required this.role});

  static const routeName = '/rencana-kebutuhan-baru';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RencanaViewModel(role: role),
      child: const _RencanaKebutuhanFlowBody(),
    );
  }
}

class _RencanaKebutuhanFlowBody extends StatelessWidget {
  const _RencanaKebutuhanFlowBody();

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
              roleLabel: 'Pembeli',
              accentColor: AppColors.orangeprimary,
              onNotificationTap: () => vm.onNotificationPressed(context),
              onSettingsTap: () => vm.onSettingsPressed(context),
            ),
            RencanaHeader(
              currentStep: vm.currentStep,
              accentColor: AppColors.orangeprimary,
              accentColorLight: AppColors.lightorange,
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
                  Page1KomoditasView(
                    title: 'Butuh komoditas apa?',
                    subtitle: 'Pilih jenis komoditas',
                    accentColor: AppColors.orangeprimary,
                    accentColorLight: AppColors.lightorange,
                  ),
                  Page2KuantitasView(
                    title: 'Butuh berapa kg?',
                    subtitle: 'Estimasi berat kebutuhan yang dibutuhkan',
                    accentColor: AppColors.orangeprimary,
                    accentColorLight: AppColors.lightorange,
                  ),
                  Page3TanggalView(
                    title: 'Kapan butuhnya?',
                    accentColor: AppColors.orangeprimary,
                    accentColorLight: AppColors.lightorange,
                    accentColorDark: AppColors.darkorange,
                  ),
                  Page4KonfirmasiView(
                    confirmationMessage:
                        'Setelah diajukan, sistem kami akan mencocokkan kebutuhanmu dengan petani yang tersedia.',
                    accentColor: AppColors.orangeprimary,
                    accentColorLight: AppColors.lightorange,
                    accentColorDark: AppColors.darkorange,
                    iconBgColor: AppColors.lightorange,
                    fallbackEmoji: '🧺',
                  ),
                ],
              ),
            ),
            RencanaBottomButton(
              label: isLastStep ? 'Sudah Benar? Cari Petani' : 'Lanjut',
              enabled: isLastStep ? !vm.isSubmitting : vm.isCurrentStepValid,
              isLoading: vm.isSubmitting,
              accentColor: AppColors.orangeprimary,
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
                        role: vm.role,
                        rencana: RencanaSummaryModel(
                          komoditasName: vm.selectedKomoditas!.name,
                          komoditasEmoji: vm.selectedKomoditas!.emoji,
                          kuantitasKg: vm.kuantitas.toInt(),
                          tanggalMulai: vm.tanggalMulai!,
                          tanggalSelesai: vm.tanggalSelesai!,
                          lokasiKirim: vm.submittedAddress ?? '-',
                        ),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal mengajukan kebutuhan, coba lagi.'),
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
