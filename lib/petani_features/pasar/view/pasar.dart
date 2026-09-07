import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/core/widget/appbar.dart';
import 'package:agrimate/core/widget/navbar_petani.dart';
import 'package:agrimate/role_selection/model/role.dart';
import 'package:agrimate/petani_features/pasar/widget/buyer_reqcard.dart';
import 'package:agrimate/petani_features/pasar/widget/pasar_theme.dart';
import '../model/pasar.dart';
import '../viewmodel/pasar_vm.dart';

class PasarView extends StatelessWidget {
  final UserRole role;

  const PasarView({super.key, this.role = UserRole.petani});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PasarViewModel>(
      create: (_) => PasarViewModel(role: role),
      child: const _PasarBody(),
    );
  }
}

class _PasarBody extends StatelessWidget {
  const _PasarBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PasarViewModel>();
    final isPetani = vm.role == UserRole.petani;
    final accentColor = isPetani
        ? AppColors.greenprimary
        : AppColors.orangeprimary;

    return Scaffold(
      backgroundColor: AppColors.scaffoldGrey,
      bottomNavigationBar: AppBottomNav(
        currentIndex: vm.currentNavIndex,
        accentColor: accentColor,
        onTap: (index) => vm.onNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeAppBar(
              roleLabel: isPetani ? 'Petani' : 'Pembeli',
              accentColor: accentColor,
              onNotificationTap: () => vm.onNotificationPressed(context),
              onSettingsTap: () => vm.onSettingsPressed(context),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPetani ? 'Cari Pembeli' : 'Pasar Komoditas',
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _SearchField(
                    initialValue: vm.searchQuery,
                    accentColor: accentColor,
                    onChanged: vm.setSearchQuery,
                  ),
                  SizedBox(height: 12.h),
                  _CommodityChips(
                    filters: vm.commodityFilters,
                    selectedId: vm.selectedCommodityId,
                    accentColor: accentColor,
                    onSelected: vm.selectCommodity,
                  ),
                  SizedBox(height: 14.h),
                  _TimelineTabs(
                    selected: vm.selectedTimeline,
                    accentColor: accentColor,
                    onSelected: vm.selectTimeline,
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.borderDefault),
            Expanded(
              child: _buildContent(context, vm, accentColor, isPetani),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PasarViewModel vm,
    Color accentColor,
    bool isPetani,
  ) {
    if (vm.state == PasarLoadState.loading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }
    if (vm.state == PasarLoadState.error) {
      return _ErrorState(
        message: vm.errorMessage ?? 'Terjadi kesalahan',
        accentColor: accentColor,
        onRetry: vm.fetchPasarData,
      );
    }

    final requests = vm.filteredRequests;
    final cardRole = isPetani ? PasarCardRole.petani : PasarCardRole.pembeli;

    return RefreshIndicator(
      color: accentColor,
      onRefresh: vm.onRefresh,
      child: requests.isEmpty
          ? _EmptyState(query: vm.searchQuery)
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
              itemCount: requests.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final request = requests[index];
                return BuyerRequestCard(
                  request: request,
                  role: cardRole,
                  onDetailTap: () {},
                  onApplyTap: () => vm.onApplyPressed(request),
                );
              },
            ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final String initialValue;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.initialValue,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: TextStyle(fontSize: 13.5.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Cari komoditas atau pembeli...',
        hintStyle: TextStyle(fontSize: 13.5.sp, color: AppColors.textMuted),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.textMuted,
          size: 20.sp,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: widget.accentColor),
        ),
      ),
    );
  }
}

class _CommodityChips extends StatelessWidget {
  final List<CommodityFilterModel> filters;
  final String selectedId;
  final Color accentColor;
  final ValueChanged<String> onSelected;

  const _CommodityChips({
    required this.filters,
    required this.selectedId,
    required this.accentColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(filter.id),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: selected ? accentColor : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: selected ? accentColor : AppColors.borderDefault,
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineTabs extends StatelessWidget {
  final PasarTimelineFilter selected;
  final Color accentColor;
  final ValueChanged<PasarTimelineFilter> onSelected;

  const _TimelineTabs({
    required this.selected,
    required this.accentColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PasarTimelineFilter.values.map((filter) {
        final isSelected = filter == selected;
        return Padding(
          padding: EdgeInsets.only(right: 20.w),
          child: GestureDetector(
            onTap: () => onSelected(filter),
            child: Container(
              padding: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? accentColor : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? accentColor : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      color: AppColors.textMuted,
                      size: 44.sp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      query.isEmpty
                          ? 'Belum ada permintaan pembeli'
                          : 'Tidak ada hasil untuk "$query"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Color accentColor;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.accentColor,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.textMuted,
            size: 40.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: accentColor),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}