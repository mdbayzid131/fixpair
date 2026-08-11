import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import '../../../data/models/user_model.dart';
import '../controllers/search_controller.dart' as search_ctrl;

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  search_ctrl.SearchController get controller =>
      Get.find<search_ctrl.SearchController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (controller.hasMore &&
          !controller.isLoadingMore.value &&
          !controller.isLoading.value) {
        controller.fetchConsultants(isLoadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar.build(
        title: 'Search Consultants'.tr,
      ),
      body: Column(
        children: [
          // 1. Search & Filter Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: TextField(
                            controller: controller.searchController,
                            onSubmitted: (_) => controller.fetchConsultants(),
                            decoration: InputDecoration(
                              hintText: 'Search by names...'.tr,
                              hintStyle: GoogleFonts.manrope(
                                fontSize: 14.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: const Color(0xFF94A3B8),
                                size: 22.sp,
                              ),
                              suffixIcon: Obx(
                                () => controller.searchQuery.value.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          color: Color(0xFF94A3B8),
                                        ),
                                        onPressed: () {
                                          controller.searchController.clear();
                                          controller.fetchConsultants();
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 18.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Obx(() {
                        final hasFilter = controller.isFilterApplied.value;
                        return GestureDetector(
                          onTap: () => _showFilterBottomSheet(context),
                          child: Container(
                            height: 56.h,
                            width: 56.h,
                            decoration: BoxDecoration(
                              color: hasFilter
                                  ? const Color(0xFFE0EFFF)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: hasFilter
                                    ? const Color(0xFF0066FF)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.filter_list_rounded,
                              color: hasFilter
                                  ? const Color(0xFF0066FF)
                                  : const Color(0xFF64748B),
                              size: 24.sp,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _buildCategoryList(),
              ],
            ),
          ),

          // 2. Expert List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.consultants.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.consultants.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No consultants found'.tr,
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount:
                    controller.consultants.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  if (index == controller.consultants.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final expert = controller.consultants[index];
                  return _buildExpertCard(expert);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: controller.categories.map((cat) {
            final isSelected = controller.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.selectCategory(cat),
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0066FF) : Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0066FF)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpertCard(UserData expert) {
    final isOnline = expert.activeStatus ?? false;
    final imageUrl = ApiConstants.getImageUrl(expert.image ?? expert.avatar);

    final consultancyType =
        (expert.consultancyType != null && expert.consultancyType!.isNotEmpty)
        ? (expert.consultancyType![0].toUpperCase() +
              expert.consultancyType!.substring(1))
        : null;

    final experience =
        (expert.experience != null && expert.experience!.trim().isNotEmpty)
        ? (expert.experience!.toLowerCase().contains("exp")
              ? expert.experience!
              : (expert.experience!.toLowerCase().contains("year") ||
                        expert.experience!.toLowerCase().contains("month")
                    ? "${expert.experience!} exp."
                    : "${expert.experience!}+ years exp."))
        : null;

    final infoText = [
      if (consultancyType != null) consultancyType,
      if (experience != null) experience,
    ].join('  •  ');

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.CONSULTANT_PROFILE, arguments: expert),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left: Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      bottomLeft: Radius.circular(24.r),
                    ),
                    child: Container(
                      width: 110.w,
                      constraints: BoxConstraints(minHeight: 110.h),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFFF1F5F9),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF1F5F9),
                              child: Icon(
                                Icons.person_rounded,
                                size: 40.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                    ),
                  ),

                  Positioned(
                    bottom: 10.h,
                    left: 10.w,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFF6B00),
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${expert.stats?.avgRating ?? 0.0} (${expert.stats?.totalReviews ?? 0})',
                            style: GoogleFonts.manrope(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Right: Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.name ?? 'No Name',
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (infoText.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          infoText,
                          style: GoogleFonts.manrope(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      // SizedBox(height: 6.h),
                      // Text(
                      //   expert.bio ?? 'No Bio available'.tr,
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: GoogleFonts.manrope(
                      //     fontSize: 13.sp,
                      //     color: const Color(0xFF475569),
                      //     fontWeight: FontWeight.w500,
                      //     height: 1.4,
                      //   ),
                      // ),
                      SizedBox(height: 10.h),
                      _buildExpertiseChips(expert.expertiseList),
                      const Spacer(),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.manrope(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              children: [
                                TextSpan(
                                  text: '${expert.perMinuteRate ?? 0}€',
                                  style: const TextStyle(
                                    color: Color(0xFF0066FF),
                                  ),
                                ),
                                TextSpan(
                                  text: '/min',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              isOnline ? 'Available'.tr : 'Offline'.tr,
                              style: GoogleFonts.manrope(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: isOnline
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Consultants'.tr,
                  style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D293D),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Price/Rate Range
            Text(
              'Per Minute Rate (€/min)'.tr,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D293D),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: TextField(
                      controller: controller.minPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D293D),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Min (€)'.tr,
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  'to'.tr,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: TextField(
                      controller: controller.maxPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D293D),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Max (€)'.tr,
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Rating Filter Options
            Text(
              'Minimum Rating'.tr,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D293D),
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() {
              final activeRating = controller.minRating.value;
              return Row(
                children: [
                  _buildRatingChip('All'.tr, 0.0, activeRating),
                  SizedBox(width: 8.w),
                  _buildRatingChip('4.0+ ★', 4.0, activeRating),
                  SizedBox(width: 8.w),
                  _buildRatingChip('4.5+ ★', 4.5, activeRating),
                ],
              );
            }),
            SizedBox(height: 24.h),

            // Sort Options
            Text(
              'Sort Options'.tr,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D293D),
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() {
              final activeSort = controller.sortBy.value;
              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildSortChip(
                    'Low to High Price'.tr,
                    'price_low_to_high',
                    activeSort,
                  ),
                  _buildSortChip(
                    'High to Low Price'.tr,
                    'price_high_to_low',
                    activeSort,
                  ),
                  _buildSortChip(
                    'Top Rated'.tr,
                    'rating_high_to_low',
                    activeSort,
                  ),
                ],
              );
            }),
            SizedBox(height: 32.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      controller.resetFilters();
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Reset All'.tr,
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilters();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filter'.tr,
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildRatingChip(String label, double rating, double activeRating) {
    final isSelected = activeRating == rating;
    return GestureDetector(
      onTap: () {
        controller.minRating.value = rating;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0EFFF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0066FF)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF0066FF)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String value, String activeSort) {
    final isSelected = activeSort == value;
    return GestureDetector(
      onTap: () {
        controller.sortBy.value = isSelected ? 'none' : value;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0EFFF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0066FF)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF0066FF)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildExpertiseChips(List<String>? expertiseList) {
    if (expertiseList == null || expertiseList.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = expertiseList.where((e) => e.trim().isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    const int maxChips = 2;
    final showMore = items.length > maxChips;
    final displayItems = showMore ? items.take(maxChips).toList() : items;

    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: [
        ...displayItems.map(
          (item) => Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              item,
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ),
        if (showMore)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '+${items.length - maxChips}',
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0066FF),
              ),
            ),
          ),
      ],
    );
  }
}
