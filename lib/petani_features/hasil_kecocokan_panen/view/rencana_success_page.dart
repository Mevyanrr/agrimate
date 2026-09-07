import 'dart:async';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/model/rencana_summary_model.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/view/matching_search_page.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/back_button.dart';
import 'package:agrimate/petani_features/hasil_kecocokan_panen/widget/rencana_summary_table_card.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RencanaSuccessPage extends StatefulWidget {
  final RencanaSummaryModel rencana;
  final UserRole role;

  const RencanaSuccessPage({
    super.key,
    required this.rencana,
    required this.role,
  });

  static const routeName = '/rencana-berhasil';

  @override
  State<RencanaSuccessPage> createState() => _RencanaSuccessPageState();
}

class _RencanaSuccessPageState extends State<RencanaSuccessPage> {
  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();
    _autoNavigateTimer = Timer(const Duration(milliseconds: 2500), _goToSearch);
  }

  void _goToSearch() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MatchingSearchPage(
          rencana: widget.rencana,
          role: widget.role,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPetani = widget.role == UserRole.petani;
    final bgColor = isPetani ? AppColors.lightgreen : AppColors.lightorange;
    final primaryColor = isPetani ? AppColors.greenprimary : AppColors.orangeprimary;
    final darkTextColor = isPetani ? AppColors.darkgreen : AppColors.darkorange;

    return Scaffold(
      backgroundColor: bgColor, 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KembaliPillButton(
                onTap: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(height: 32.h),
              Center(
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: primaryColor, 
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.check, color: Colors.white, size: 36.sp),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  isPetani ? 'Rencana Berhasil Dibuat' : 'Kebutuhan Berhasil Dibuat', 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  isPetani
                      ? 'Data rencana panen Anda telah kami simpan.'
                      : 'Data rencana kebutuhan Anda telah kami simpan.', 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              RencanaSummaryTableCard(rencana: widget.rencana),
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: bgColor, 
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: primaryColor.withOpacity(0.3)), 
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: primaryColor, 
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.info, color: Colors.white, size: 13.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        isPetani
                            ? 'Sistem AgriMate sedang mencarikan kebutuhan yang sesuai dengan rencana panen Anda. Kami akan memberitahu Anda segera.'
                            : 'Sistem AgriMate sedang mencarikan ketersediaan panen yang sesuai dengan kebutuhan Anda. Kami akan memberitahu Anda segera.', // ✅ Deskripsi info dinamis
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: darkTextColor, 
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}