import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/rencana_panen/viewmodel/rencana_panen_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Page2KuantitasView extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color accentColorLight;

  const Page2KuantitasView({
    super.key,
    this.title = 'Kira-kira berapa kg?',
    this.subtitle = 'Estimasi total yang dapat dipanen',
    this.accentColor = AppColors.greenprimary,
    this.accentColorLight = AppColors.lightgreen,
  });

  static const List<double> quickPicks = [50, 100, 500, 1000];

  @override
  State<Page2KuantitasView> createState() => _Page2KuantitasViewState();
}

class _Page2KuantitasViewState extends State<Page2KuantitasView> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final vm = context.read<RencanaViewModel>();
    _controller = TextEditingController(
      text: vm.kuantitas > 0 ? vm.kuantitas.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(double value, RencanaViewModel vm) {
    vm.setKuantitas(value);
    _controller.text = value > 0 ? value.toInt().toString() : '';
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RencanaViewModel>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            widget.subtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: widget.accentColor,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                      isDense: true,
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0;
                      vm.setKuantitas(parsed);
                    },
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _updateValue(vm.kuantitas + 1, vm),
                      child: Icon(Icons.arrow_drop_up, color: Colors.grey.shade600, size: 24.r),
                    ),
                    InkWell(
                      onTap: () {
                        if (vm.kuantitas > 0) {
                          _updateValue(vm.kuantitas - 1, vm);
                        }
                      },
                      child: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 24.r),
                    ),
                  ],
                ),
                SizedBox(width: 8.w),
                Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          Text(
            'Atau pilih cepat:',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),

          Row(
            children: Page2KuantitasView.quickPicks.map((value) {
              final isSelected = vm.kuantitas == value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: OutlinedButton(
                    onPressed: () => _updateValue(value, vm),
                    style: OutlinedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: isSelected ? widget.accentColor : Colors.white,
                      side: BorderSide(
                        color: isSelected ? widget.accentColor : Colors.grey.shade300,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}