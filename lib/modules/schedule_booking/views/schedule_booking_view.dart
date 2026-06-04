import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/helpers.dart';
import '../controllers/schedule_booking_controller.dart';

class ScheduleBookingView extends GetView<ScheduleBookingController> {
  const ScheduleBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: const Color(0xFF1D293D),
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Schedule Booking',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.dates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No available slots found',
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(
                context,
                '1. Select Date',
                DateFormat('MMMM yyyy').format(controller.focusedDate.value),
                onPrev: controller.previousMonth,
                onNext: controller.nextMonth,
              ),
              SizedBox(height: 16.h),
              _buildMonthCalendar(),
              SizedBox(height: 32.h),
              _buildSectionHeader('2. Select Time', 'Germany (CET)'),
              SizedBox(height: 16.h),
              _buildTimeGrid(),
              _buildDurationSelector(),
              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomConfirmBar(),
    );
  }

  Widget _buildDateHeader(
    BuildContext context,
    String title,
    String tag, {
    required VoidCallback onPrev,
    required VoidCallback onNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1D293D),
          ),
        ),
        Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: Icon(
                  Icons.chevron_left_rounded,
                  size: 20.sp,
                  color: const Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(maxWidth: 32.w),
              ),
              Text(
                tag,
                style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: const Color(0xFF64748B),
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(maxWidth: 32.w),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String tag) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1D293D),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            tag,
            style: GoogleFonts.manrope(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthCalendar() {
    return Obx(() {
      final focused = controller.focusedDate.value;
      final year = focused.year;
      final month = focused.month;

      final firstDayOfMonth = DateTime(year, month, 1);
      final totalDays = DateTime(year, month + 1, 0).day;

      final startOffset = firstDayOfMonth.weekday - 1;

      final List<Widget> dayWidgets = [];

      final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      for (var day in weekdays) {
        dayWidgets.add(
          Center(
            child: Text(
              day,
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
        );
      }

      for (var i = 0; i < startOffset; i++) {
        dayWidgets.add(const SizedBox.shrink());
      }

      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

      String? selectedDateKey;
      if (controller.selectedDateIndex.value != -1 &&
          controller.dates.isNotEmpty) {
        selectedDateKey =
            controller.dates[controller.selectedDateIndex.value]['fullDate'];
      }

      for (var day = 1; day <= totalDays; day++) {
        final currentDayObj = DateTime(year, month, day);
        final dateKey = DateFormat('yyyy-MM-dd').format(currentDayObj);
        final hasSlots = controller.slotsByDate.containsKey(dateKey);

        final isSelected = selectedDateKey == dateKey;
        final isToday = todayKey == dateKey;

        dayWidgets.add(
          GestureDetector(
            onTap: hasSlots
                ? () {
                    final index = controller.dates.indexWhere(
                      (d) => d['fullDate'] == dateKey,
                    );
                    if (index != -1) {
                      controller.selectDate(index);
                    }
                  }
                : null,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF0066FF)
                      : (isToday
                            ? const Color(0xFFEFF6FF)
                            : Colors.transparent),
                  border: isToday && !isSelected
                      ? Border.all(color: const Color(0xFF0066FF), width: 1.w)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF0066FF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '$day',
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (hasSlots
                                  ? const Color(0xFF1D293D)
                                  : const Color(0xFFCBD5E1)),
                      ),
                    ),
                    if (hasSlots && !isSelected)
                      Positioned(
                        bottom: 4.h,
                        child: Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B00),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: GridView.custom(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 1.0,
          ),
          childrenDelegate: SliverChildListDelegate(dayWidgets),
        ),
      );
    });
  }

  Widget _buildTimeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.3,
      ),
      itemCount: controller.times.length,
      itemBuilder: (context, index) {
        final time = controller.times[index];
        return Obx(() {
          final isSelected = controller.selectedTimeIndex.value == index;

          final dateIndex = controller.selectedDateIndex.value;
          final bool isBooked;
          if (dateIndex >= 0 && dateIndex < controller.dates.length) {
            final selectedDateKey = controller.dates[dateIndex]['fullDate'];
            final slots = controller.slotsByDate[selectedDateKey] ?? [];
            isBooked = index < slots.length && slots[index].isBooked == true;
          } else {
            isBooked = false;
          }

          return GestureDetector(
            onTap: isBooked
                ? () => Helpers.showWarning('This time slot is already booked.')
                : () => controller.selectStartTime(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isBooked
                    ? const Color(0xFFF1F5F9)
                    : (isSelected ? const Color(0xFF0066FF) : Colors.white),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isBooked
                      ? const Color(0xFFE2E8F0)
                      : (isSelected
                            ? const Color(0xFF0066FF)
                            : const Color(0xFFE2E8F0)),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isBooked
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Booked',
                            style: GoogleFonts.manrope(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                      ),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildDurationSelector() {
    return Obx(() {
      if (controller.selectedStartTime.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32.h),
          _buildSectionHeader('3. Select Duration', 'Based on availability'),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: controller.durationOptions.map((option) {
                final int duration = option['duration'];
                final String label = option['label'];
                final bool isEnabled = option['isEnabled'];
                final String endTime = option['endTime'];
                final isSelected =
                    controller.selectedDurationMinutes.value == duration;

                // Calculate price for this duration
                final rate = controller.expert.value?.perMinuteRate ?? 0;
                final price = duration * rate;

                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: isEnabled
                        ? () {
                            controller.selectedDurationMinutes.value = duration;
                          }
                        : () {
                            Helpers.showWarning(
                              'This duration is not available because it overlaps with a booked or unavailable slot.',
                            );
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 135.w,
                      height: 100.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0066FF)
                            : (isEnabled
                                  ? Colors.white
                                  : const Color(0xFFF8FAFC)),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0066FF)
                              : (isEnabled
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFFE2E8F0)),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0066FF,
                                  ).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                label,
                                style: GoogleFonts.manrope(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : (isEnabled
                                            ? const Color(0xFF1D293D)
                                            : const Color(0xFF94A3B8)),
                                  decoration: isEnabled
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              if (!isEnabled)
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 14.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Ends at $endTime',
                            style: GoogleFonts.manrope(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.8)
                                  : (isEnabled
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8)),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '€${price.toStringAsFixed(2)}',
                            style: GoogleFonts.manrope(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : (isEnabled
                                        ? const Color(0xFFFF6B00)
                                        : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBottomConfirmBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
          child: Obx(() {
            final hasSelectedTime = controller.selectedStartTime.isNotEmpty;
            final selectedDate =
                controller.dates.isNotEmpty &&
                    controller.selectedDateIndex.value != -1
                ? controller.dates[controller.selectedDateIndex.value]
                : null;
            final dateObj = selectedDate != null
                ? DateTime.parse(selectedDate['fullDate']!)
                : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL PRICE (INKL. MWST)',
                          style: GoogleFonts.manrope(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: controller.totalPrice.toStringAsFixed(2),
                                style: GoogleFonts.manrope(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1D293D),
                                ),
                              ),
                              TextSpan(
                                text: '€',
                                style: GoogleFonts.manrope(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1D293D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (selectedDate != null && dateObj != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16.sp,
                                color: const Color(0xFF64748B),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${DateFormat('MMM').format(dateObj)} ${selectedDate['date']}, ${dateObj.year}',
                                style: GoogleFonts.manrope(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1D293D),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16.sp,
                                color: const Color(0xFF64748B),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                !hasSelectedTime
                                    ? 'Select time'
                                    : '${controller.selectedStartTime.value} - ${controller.addMinutesToTime(controller.selectedStartTime.value, controller.selectedDurationMinutes.value)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1D293D),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: hasSelectedTime
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B00), Color(0xFFFF8A00)],
                          )
                        : null,
                    color: hasSelectedTime ? null : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: hasSelectedTime
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFF6B00,
                              ).withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasSelectedTime
                          ? () => controller.bookScheduled()
                          : null,
                      borderRadius: BorderRadius.circular(16.r),
                      child: Center(
                        child: Text(
                          'Confirm Booking',
                          style: GoogleFonts.manrope(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: hasSelectedTime
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
