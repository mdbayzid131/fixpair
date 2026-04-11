import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/search_controller.dart' as search_ctrl;

class SearchView extends GetView<search_ctrl.SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Find Consultant',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.filter_list_rounded,
              color: const Color(0xFF64748B),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 8.w),
        ],
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
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search specialties, names...',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFF94A3B8),
                          size: 22.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _buildCategoryList(),
              ],
            ),
          ),

          // 2. Expert List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(24.w),
              itemCount: 4,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final experts = [
                  {
                    'name': 'Dr. Thomas Weber',
                    'role': 'General Medicine',
                    'desc':
                        'Friendly general practitioner available for quick medical',
                    'rating': '4.9',
                    'reviews': '124',
                    'price': '4.00€/min',
                    'status': 'Online Now',
                    'image': 'https://i.pravatar.cc/150?u=thomas',
                  },
                  {
                    'name': 'Sarah Müller',
                    'role': 'Tax Consultation',
                    'desc':
                        'Certified Tax Advisor (Steuerberater) with expertise',
                    'rating': '4.8',
                    'reviews': '89',
                    'price': '4.00€/min',
                    'status': 'Online Now',
                    'image': 'https://i.pravatar.cc/150?u=sarah',
                  },
                  {
                    'name': 'Dr. Elena Schmidt',
                    'role': 'General Medicine',
                    'desc':
                        'Friendly general practitioner available for quick medical',
                    'rating': '4.9',
                    'reviews': '210',
                    'price': '4.00€/min',
                    'status': 'Available Later',
                    'image': 'https://i.pravatar.cc/150?u=elena',
                  },
                  {
                    'name': 'Marcus Fischer',
                    'role': 'Immigration Law',
                    'desc':
                        'Dedicated immigration lawyer helping with visas and',
                    'rating': '4.7',
                    'reviews': '56',
                    'price': '4.00€/min',
                    'status': 'Online Now',
                    'image': 'https://i.pravatar.cc/150?u=marcus',
                  },
                ];
                final expert = experts[index];
                return _buildExpertCard(expert);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
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

  Widget _buildExpertCard(Map<String, String> expert) {
    final isOnline = expert['status'] == 'Online Now';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left: Image
            Stack(
              children: [
                Container(
                  width: 110.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      bottomLeft: Radius.circular(24.r),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(expert['image']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: isOnline ? const Color(0xFF10B981) : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
                          '${expert['rating']} (${expert['reviews']})',
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
                      expert['name']!,
                      style: GoogleFonts.manrope(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                    Text(
                      expert['role']!,
                      style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      expert['desc']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        color: const Color(0xFF94A3B8),
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D293D),
                            ),
                            children: [
                              TextSpan(text: expert['price']!.split('/')[0]),
                              TextSpan(
                                text: '/${expert['price']!.split('/')[1]}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
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
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            expert['status']!,
                            style: GoogleFonts.manrope(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: isOnline
                                  ? const Color(0xFF10B981)
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
    );
  }
}
