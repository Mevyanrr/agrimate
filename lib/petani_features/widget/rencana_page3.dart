import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/petani_features/home/viewmodel/rencana_panen_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';


class Page3TanggalView extends StatelessWidget {
  const Page3TanggalView({super.key});

  static const List<String> _bulanPendek = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  static const List<String> _hariPendek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RencanaViewModel>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kapan perkiraan panen',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 4.h),
          Text(
            'Pilih rentang tanggal',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              children: [
                _MonthYearSelector(vm: vm, bulanPendek: _bulanPendek),
                SizedBox(height: 12.h),
                _WeekdayHeader(hariPendek: _hariPendek),
                SizedBox(height: 4.h),
                _CalendarGrid(vm: vm),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.lightgreen,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16.sp, color: AppColors.darkgreen),
                SizedBox(width: 8.w),
                Text(
                  'Estimasi durasi panen:',
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${vm.durasiHari} Hari',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkgreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthYearSelector extends StatelessWidget {
  final RencanaViewModel vm;
  final List<String> bulanPendek;

  const _MonthYearSelector({required this.vm, required this.bulanPendek});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(6, (i) => currentYear - 1 + i);

    return Row(
      children: [
        IconButton(
          onPressed: () => vm.changeMonth(-1),
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 20.sp),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
        ),
        Expanded(
          child: _Dropdown<int>(
            value: vm.calendarMonth.month,
            items: List.generate(12, (i) => i + 1),
            labelBuilder: (m) => bulanPendek[m - 1],
            onChanged: (m) => vm.setMonth(m!),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _Dropdown<int>(
            value: vm.calendarMonth.year,
            items: years,
            labelBuilder: (y) => y.toString(),
            onChanged: (y) => vm.setYear(y!),
          ),
        ),
        IconButton(
          onPressed: () => vm.changeMonth(1),
          icon: Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 20.sp),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderDefault),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 18.sp, color: AppColors.textSecondary),
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(labelBuilder(e))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final List<String> hariPendek;
  const _WeekdayHeader({required this.hariPendek});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: hariPendek
          .map(
            (h) => Expanded(
              child: Center(
                child: Text(
                  h,
                  style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final RencanaViewModel vm;
  const _CalendarGrid({required this.vm});

  @override
  Widget build(BuildContext context) {
    final month = vm.calendarMonth;
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstDayOfMonth.weekday % 7; 

    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    final prevMonthLastDay = DateTime(month.year, month.month, 0).day;

    final cells = <DateTime>[];
    for (int i = 0; i < totalCells; i++) {
      final dayNumber = i - leadingBlanks + 1;
      if (dayNumber < 1) {
        cells.add(DateTime(month.year, month.month - 1, prevMonthLastDay + dayNumber));
      } else if (dayNumber > daysInMonth) {
        cells.add(DateTime(month.year, month.month + 1, dayNumber - daysInMonth));
      } else {
        cells.add(DateTime(month.year, month.month, dayNumber));
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4.h,
        crossAxisSpacing: 2.w,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final date = cells[index];
        final isCurrentMonth = date.month == month.month;
        return _DateCell(date: date, isCurrentMonth: isCurrentMonth, vm: vm);
      },
    );
  }
}

class _DateCell extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final RencanaViewModel vm;

  const _DateCell({required this.date, required this.isCurrentMonth, required this.vm});

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final start = vm.tanggalMulai;
    final end = vm.tanggalSelesai;

    final isStart = start != null && _isSameDay(date, start);
    final isEnd = end != null && _isSameDay(date, end);
    final isInRange = start != null && end != null && date.isAfter(start) && date.isBefore(end);

    Color? bgColor;
    Color textColor = AppColors.textPrimary;
    FontWeight fontWeight = FontWeight.normal;

    if (!isCurrentMonth) {
      textColor = AppColors.textMuted;
    }
    if (isInRange) {
      bgColor = AppColors.scaffoldGrey;
      textColor = AppColors.textPrimary;
    }
    if (isStart || isEnd) {
      bgColor = AppColors.greenprimary;
      textColor = Colors.white;
      fontWeight = FontWeight.w700;
    }

    return InkWell(
      onTap: () => vm.selectDate(DateTime(date.year, date.month, date.day)),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: bgColor,
          shape: (isStart || isEnd) ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: (isStart || isEnd) ? null : BorderRadius.circular(6.r),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(fontSize: 13.sp, color: textColor, fontWeight: fontWeight),
        ),
      ),
    );
  }
}