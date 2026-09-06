import 'package:agrimate/core/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PulsingRings extends StatefulWidget {
  final String emoji;
  const PulsingRings({super.key, required this.emoji});

  @override
  State<PulsingRings> createState() => _PulsingRingsState();
}

class _PulsingRingsState extends State<PulsingRings> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = 220.w;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _ring(size, delay: 0.0),
              _ring(size, delay: 0.5),
              Container(
                width: size * 0.55,
                height: size * 0.55,
                decoration: const BoxDecoration(color: AppColors.greenprimary, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(widget.emoji, style: TextStyle(fontSize: 40.sp)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(double maxSize, {required double delay}) {
    final t = (_controller.value + delay) % 1.0;
    final scale = 0.55 + (t * 0.45); // dari 55% -> 100% ukuran container
    final opacity = (1 - t).clamp(0.0, 1.0) * 0.35;

    return Opacity(
      opacity: opacity,
      child: Container(
        width: maxSize * scale,
        height: maxSize * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.greenprimary, width: 1.5),
        ),
      ),
    );
  }
}