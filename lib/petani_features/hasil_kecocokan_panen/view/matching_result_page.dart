import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/matching_result_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/viewmodel/matching_result_viewmodel.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/back_button.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/matching_bottom_actions.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/matching_buyer_card.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/matching_summary_header_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MatchingResultPage extends StatelessWidget {
  final MatchingResultModel result;
  const MatchingResultPage({super.key, required this.result});

  static const routeName = '/hasil-kecocokan';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchingResultViewModel(result: result),
      child: const _MatchingResultBody(),
    );
  }
}

class _MatchingResultBody extends StatelessWidget {
  const _MatchingResultBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MatchingResultViewModel>();
    final result = vm.result;

    return Scaffold(
      backgroundColor: AppColors.scaffoldGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
              ),
              child: Row(
                children: [
                  KembaliPillButton(onTap: () => Navigator.of(context).maybePop()),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Hasil Kecocokan',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.purpleAccentLight,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${result.matchCount} cocok',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.purpleAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 160.h), 
                    children: [
                      MatchingSummaryHeaderCard(result: result),
                      SizedBox(height: 20.h),
                      Text(
                        'Pembeli yang Cocok',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ...result.buyers.map(
                        (buyer) => MatchingBuyerCard(
                          buyer: buyer,
                          isLoading: vm.isBuyerLoading(buyer.id),
                          onRespond: (accept) => vm.respond(buyer.id, accept),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: MatchingBottomActions(
                      onLihatKebutuhan: () {
                        
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (_) => MatchingSearchPage(rencana: result.rencana),
                        //   ),
                        // );
                      },
                      onKembaliBeranda: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}