import 'dart:io';
import 'package:agrimate/core/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../viewmodel/lengkapi_profil_vm.dart';

class LengkapiProfilView extends StatelessWidget {
  const LengkapiProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LengkapiProfilViewModel(),
      child: const _LengkapiProfilBody(),
    );
  }
}

class _LengkapiProfilBody extends StatelessWidget {
  const _LengkapiProfilBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LengkapiProfilViewModel>();
    final isSubmitting = vm.submitState == SubmitState.submitting;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo_withname.png',
                  height: 90.h,
                  
                ),
              ),
              SizedBox(height: 20.h),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    const TextSpan(text: 'Lengkapi '),
                    TextSpan(
                      text: 'Profilmu',
                      style: TextStyle(color: AppColors.greenprimary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Langkah terakhir! Lengkapi data dirimu di bawah ini '
                'untuk mulai menggunakan AgriMate.',
                style: TextStyle(fontSize: 12.5.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 20.h),
              const _SectionDivider(),
              SizedBox(height: 18.h),
              const _SectionTitle('Informasi Dasar'),
              SizedBox(height: 14.h),
              _ProfileTextField(
                label: 'Nama Lengkap Sesuai KTP',
                hint: 'contoh: Budi Santoso',
                controller: vm.namaController,
                errorText: vm.namaError,
              ),
              SizedBox(height: 16.h),
              _ProfileTextField(
                label: 'Nomor WhatsApp',
                hint: 'contoh: 08512345678',
                controller: vm.whatsappController,
                errorText: vm.whatsappError,
                keyboardType: TextInputType.phone,
                maxLength: 15,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 20.h),
              const _SectionDivider(),
              SizedBox(height: 18.h),
              const _SectionTitle('Informasi Pertanian'),
              SizedBox(height: 14.h),
              Text(
                'Foto Lahan Pertanian',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              _PhotoUploadBox(
                title: 'Ketuk untuk Unggah Foto Lahan',
                subtitle:
                    'Format JPG/PNG, maks. 5MB. Membantu pembeli lebih percaya.',
                file: vm.fotoLahan,
                onTap: vm.pickFotoLahan,
              ),
              SizedBox(height: 16.h),
              _ProfileTextField(
                label: 'Luas Lahan (Hektar) - Opsional',
                hint: 'contoh: 2.5',
                controller: vm.luasLahanController,
                errorText: vm.luasLahanError,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                ],
              ),
              SizedBox(height: 16.h),
              _ProfileTextField(
                label: 'Alamat Lahan / Kelompok Tani',
                hint: 'Masukkan alamat lengkap atau nama kelompok tani',
                controller: vm.alamatLahanController,
                errorText: vm.alamatLahanError,
              ),
              SizedBox(height: 20.h),
              const _SectionDivider(),
              SizedBox(height: 18.h),
              const _SectionTitle('Verifikasi Identitas'),
              SizedBox(height: 14.h),
              _ProfileTextField(
                label: 'NIK KTP (Wajib)',
                hint: 'Masukkan 16 digit NIK',
                controller: vm.nikController,
                errorText: vm.nikError,
                keyboardType: TextInputType.number,
                maxLength: 16,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 16.h),
              Text(
                'Foto KTP (Opsional)',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              _PhotoUploadBox(
                title: 'Ketuk untuk Unggah Foto KTP',
                subtitle:
                    'Format JPG/PNG, maks. 5MB. Pastikan seluruh kartu terlihat '
                    'tanpa terpotong.',
                file: vm.fotoKtp,
                onTap: vm.pickFotoKtp,
              ),
              SizedBox(height: 28.h),
              if (vm.submitError != null) ...[
                Text(
                  vm.submitError!,
                  style: const TextStyle(color: Color(0xFFE05353), fontSize: 12),
                ),
                SizedBox(height: 10.h),
              ],
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : () => vm.submit(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenprimary,
                    disabledBackgroundColor: AppColors.greenprimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 22.w,
                          height: 22.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Daftar Akun Sekarang →',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.borderDefault);
  }
}

class _ProfileTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const _ProfileTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.inputFormatters,
  });

  static const _errorColor = Color(0xFFE05353);

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.trim().isNotEmpty;
    final hasError = errorText != null;

    final Color borderColor = hasError
        ? _errorColor
        : hasValue
            ? AppColors.greenprimary
            : AppColors.borderDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: TextStyle(fontSize: 13.5.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13.5.sp, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.scaffoldGrey,
            counterText: '',
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: borderColor,
                width: hasValue || hasError ? 1.4 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: borderColor,
                width: hasValue || hasError ? 1.4 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: hasError ? _errorColor : AppColors.greenprimary,
                width: 1.6,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            errorText!,
            style: TextStyle(fontSize: 11.sp, color: _errorColor),
          ),
        ],
      ],
    );
  }
}

class _PhotoUploadBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final File? file;
  final VoidCallback onTap;

  const _PhotoUploadBox({
    required this.title,
    required this.subtitle,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: file != null
              ? AppColors.greenprimary
              : AppColors.greenprimary.withOpacity(0.5),
          radius: 16.r,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
          child: file != null ? _buildSelected(file!) : _buildEmpty(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.lightgreen,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.image_outlined,
            color: AppColors.greenprimary,
            size: 22.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildSelected(File selectedFile) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            selectedFile,
            height: 110.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.greenprimary, size: 15.sp),
            SizedBox(width: 4.w),
            Text(
              'Foto berhasil dipilih. Ketuk untuk mengganti.',
              style: TextStyle(fontSize: 11.sp, color: AppColors.greenprimary),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const _DashedBorderPainter({
    required this.color,
    this.radius = 16,
    this.strokeWidth = 1.4,
    this.dashWidth = 6,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    canvas.drawPath(_dashPath(path), paint);
  }

  Path _dashPath(Path source) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}