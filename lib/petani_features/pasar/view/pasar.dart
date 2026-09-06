import 'package:agrimate/core/appcolor.dart';
import 'package:agrimate/core/widget/navbar_petani.dart';
import 'package:agrimate/petani_features/pasar/widget/buyer_reqcard.dart';
import 'package:agrimate/petani_features/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../model/pasar.dart';
import '../viewmodel/pasar_vm.dart';

class PasarView extends StatelessWidget {
  const PasarView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasarViewModel(),
      child: const _PasarBody(),
    );
  }
}

class _PasarBody extends StatelessWidget {
  const _PasarBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PasarViewModel>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldGrey,
      bottomNavigationBar: AppBottomNav(
        currentIndex: vm.currentNavIndex,
        accentColor: AppColors.greenprimary,
        onTap: (index) => vm.onNavTap(context, index),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            HomeAppBar(
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
                    'Cari Pembeli',
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _SearchField(
                    initialValue: vm.searchQuery,
                    onChanged: vm.setSearchQuery,
                  ),
                  SizedBox(height: 12.h),
                  _CommodityChips(
                    filters: vm.commodityFilters,
                    selectedId: vm.selectedCommodityId,
                    onSelected: vm.selectCommodity,
                  ),
                  SizedBox(height: 14.h),
                  _TimelineTabs(
                    selected: vm.selectedTimeline,
                    onSelected: vm.selectTimeline,
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.borderDefault),
            Expanded(child: _buildContent(context, vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PasarViewModel vm) {
    if (vm.state == PasarLoadState.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.greenprimary),
      );
    }
    if (vm.state == PasarLoadState.error) {
      return _ErrorState(
        message: vm.errorMessage ?? 'Terjadi kesalahan',
        onRetry: vm.fetchPasarData,
      );
    }

    final requests = vm.filteredRequests;

    return RefreshIndicator(
      color: AppColors.greenprimary,
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
                  onDetailTap: () => vm.onDetailPressed(context, request),
                  onApplyTap: () => vm.onApplyPressed(request),
                );
              },
            ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.initialValue, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

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
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: AppColors.greenprimary),
        ),
      ),
    );
  }
}

class _CommodityChips extends StatelessWidget {
  final List<CommodityFilterModel> filters;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _CommodityChips({
    required this.filters,
    required this.selectedId,
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
                color: selected ? AppColors.greenprimary : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: selected ? AppColors.greenprimary : AppColors.borderDefault,
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
  final ValueChanged<PasarTimelineFilter> onSelected;

  const _TimelineTabs({required this.selected, required this.onSelected});

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
                    color: isSelected ? AppColors.greenprimary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.greenprimary : AppColors.textSecondary,
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
                    Icon(Icons.storefront_outlined, color: AppColors.textMuted, size: 44.sp),
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
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.textMuted, size: 40.sp),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
          ),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenprimary),
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}