import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/splash_onboarding/model/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../viewmodel/onboarding_vm.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<OnboardingViewModel>(
        builder: (context, vm, _) {
          return Stack(
            children: [
              PageView.builder(
                controller: vm.pageController,
                onPageChanged: vm.onPageChanged,
                itemCount: vm.pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingSlide(data: vm.pages[index]);
                },
              ),

              Positioned(
                top: 50.h,
                right: 20.w,
                child: GestureDetector(
                  onTap: () => vm.onSkipPressed(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Lewati',
                      style: TextStyle(
                        color: AppColors.darkgreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 24.w,
                right: 24.w,
                bottom: 32.h,
                child: Column(
                  children: [
                    _PageIndicator(
                      pageCount: vm.pages.length,
                      currentPage: vm.currentPage,
                    ),
                    SizedBox(height: 24.h),
                    _CtaButton(
                      text: vm.pages[vm.currentPage].buttonText,
                      showArrow: !vm.isLastPage,
                      onTap: () => vm.onNextPressed(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final OnboardingModel data;

  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: screenHeight * 0.58,
          width: double.infinity,
          child: Image.asset(
            data.imagePath,
            fit: BoxFit.cover,
          ),
        ),

        Transform.translate(
          offset: Offset(0, -32.h),
          child: Container(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 140.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.r),
                topRight: Radius.circular(32.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F5E9),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: SvgPicture.asset(
    data.iconPath,
    fit: BoxFit.contain,
    width: 33.w,
    height: 33.w,
  ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  data.description,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: const Color(0xFF6F7787),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class _PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const _PageIndicator({
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF27AE60)
                : const Color(0xFFE2E5E9),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String text;
  final bool showArrow;
  final VoidCallback onTap;

  const _CtaButton({
    required this.text,
    required this.showArrow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF27AE60),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showArrow) ...[
              SizedBox(width: 8.w),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}