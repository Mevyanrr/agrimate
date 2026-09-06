import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/rencana_summary_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/view/matching_result_page.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/viewmodel/matching_search_viewmodel.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/back_button.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/matching_mini_summary_card.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/pulsing_rings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MatchingSearchPage extends StatelessWidget {
  final RencanaSummaryModel rencana;
  const MatchingSearchPage({super.key, required this.rencana});

  static const routeName = '/mencari-pembeli';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchingSearchViewModel(rencana: rencana),
      child: const _MatchingSearchBody(),
    );
  }
}

class _MatchingSearchBody extends StatefulWidget {
  const _MatchingSearchBody();

  @override
  State<_MatchingSearchBody> createState() => _MatchingSearchBodyState();
}

class _MatchingSearchBodyState extends State<_MatchingSearchBody> {
  bool _navigated = false;

  void _navigateWhenDone(MatchingSearchViewModel vm) {
    if (_navigated || !vm.isDone) return;
    _navigated = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MatchingResultPage(result: vm.result!)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MatchingSearchViewModel>();
    _navigateWhenDone(vm);

    return Scaffold(
      backgroundColor: AppColors.lightgreen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              KembaliPillButton(onTap: () => Navigator.of(context).maybePop()),
              SizedBox(height: 60.h),
              Center(child: PulsingRings(emoji: vm.rencana.komoditasEmoji)),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  'Sedang mencarikan pembeli...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(height: 20.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: SizedBox(
                  height: 6.h,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.borderDefault,
                    valueColor: const AlwaysStoppedAnimation(AppColors.greenprimary),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    vm.statusMessage,
                    key: ValueKey(vm.statusMessage),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const Spacer(),
              MatchingMiniSummaryCard(rencana: vm.rencana),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}