import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Title / Logo
                  Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: const Icon(
                          Icons.handyman_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Fixpair',
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1D293D),
                        ),
                      ),
                    ],
                  ),
                  // Skip Button
                  Obx(() {
                    if (controller.isLastPage) {
                      return SizedBox(width: 48.w); // Spacer to maintain layout
                    }
                    return TextButton(
                      onPressed: () => controller.skipOnboarding(),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Page View for Slides
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSlideWelcome(),
                  _buildSlideNavigation(),
                  _buildSlideBooking(),
                  _buildSlideVideoCall(),
                  _buildSlidePayment(),
                ],
              ),
            ),

            // Bottom controls: Indicators & Next Button
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Page Indicators
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) => _buildIndicator(index)),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Next / Get Started Button
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: () => controller.nextPage(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          controller.isLastPage
                              ? (controller.fromProfile ? 'Close Tutorial' : 'Get Started')
                              : 'Next',
                          style: GoogleFonts.manrope(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    final isSelected = controller.currentPage.value == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      height: 8.h,
      width: isSelected ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  // Slide 1: Welcome & Overview
  Widget _buildSlideWelcome() {
    return _buildSlideContainer(
      title: 'Welcome to Fixpair',
      description: 'Your premium gateway to professional consulting across Germany. Connect instantly with legal, medical, and advisory experts.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glowing Radial Background Logo
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE0EFFF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066FF).withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.handyman_rounded,
              color: const Color(0xFF0066FF),
              size: 64.sp,
            ),
          ),
          SizedBox(height: 40.h),
          // Features grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                _buildWelcomeFeature(
                  icon: Icons.video_call_rounded,
                  title: 'Instant Video Consultations',
                  desc: 'High-quality live audio/video calls with experts.',
                ),
                SizedBox(height: 16.h),
                _buildWelcomeFeature(
                  icon: Icons.people_alt_rounded,
                  title: 'Verified Professionals',
                  desc: 'Hand-picked lawyers, doctors, and advisors.',
                ),
                SizedBox(height: 16.h),
                _buildWelcomeFeature(
                  icon: Icons.verified_user_rounded,
                  title: 'Secure and Confidential',
                  desc: 'Protected end-to-end stripe payments.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeFeature({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0066FF), size: 22.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D293D),
                ),
              ),
              Text(
                desc,
                style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Slide 2: Navigation Help
  Widget _buildSlideNavigation() {
    return _buildSlideContainer(
      title: 'Easy Navigation',
      description: 'Explore the core features of the app through a simple, responsive bottom navigation bar.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium Mockup Card
          Container(
            padding: EdgeInsets.all(20.w),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildNavigationFeatureItem(
                  icon: Icons.home_rounded,
                  title: 'Home Dashboard',
                  desc: 'Discover recommended experts, browse categories, and join upcoming sessions.',
                  isActive: true,
                ),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildNavigationFeatureItem(
                  icon: Icons.search_rounded,
                  title: 'Search Directory',
                  desc: 'Search, filter, and discover experts by expertise or category.',
                  isActive: false,
                ),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildNavigationFeatureItem(
                  icon: Icons.calendar_month_rounded,
                  title: 'Consultation History',
                  desc: 'Manage your completed and scheduled appointments easily.',
                  isActive: false,
                ),
                const Divider(height: 24, color: Color(0xFFF1F5F9)),
                _buildNavigationFeatureItem(
                  icon: Icons.person_rounded,
                  title: 'Profile Settings',
                  desc: 'Update personal details, payment cards, and access legal/support.',
                  isActive: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationFeatureItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFE0EFFF) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? const Color(0xFF0066FF) : const Color(0xFF94A3B8),
            size: 22.sp,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive ? const Color(0xFF0066FF) : const Color(0xFF1D293D),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                desc,
                style: GoogleFonts.manrope(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Slide 3: Smart Search & Booking
  Widget _buildSlideBooking() {
    return _buildSlideContainer(
      title: 'Find & Book Experts',
      description: 'Filter professionals by category, check rating scores, see active statuses, and book a video session.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Miniature categories header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniBadge('LAWYER', isSelected: true),
              SizedBox(width: 8.w),
              _buildMiniBadge('DOCTOR', isSelected: false),
              SizedBox(width: 8.w),
              _buildMiniBadge('ADVISOR', isSelected: false),
            ],
          ),
          SizedBox(height: 24.h),

          // Expert Card Mockup
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with online status
                Stack(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.person, color: const Color(0xFF94A3B8), size: 36.sp),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Online
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0EFFF),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'LAWYER',
                              style: GoogleFonts.manrope(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0066FF),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star_rounded, color: const Color(0xFFFF6B00), size: 14.sp),
                              SizedBox(width: 2.w),
                              Text(
                                '5.0',
                                style: GoogleFonts.manrope(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1D293D),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Dr. Michael Schmidt',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D293D),
                        ),
                      ),
                      Text(
                        'Employment & Civil Law Expert',
                        style: GoogleFonts.manrope(
                          fontSize: 11.sp,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '1.50€/min',
                            style: GoogleFonts.manrope(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D293D),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066FF),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Book',
                              style: GoogleFonts.manrope(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, {required bool isSelected}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0066FF) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFCBD5E1)),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }

  // Slide 4: Video Call & Push Notifications
  Widget _buildSlideVideoCall() {
    return _buildSlideContainer(
      title: 'Instant Video Calls',
      description: 'Experience crisp HD video sessions directly inside the app, powered by Agora RTC. Answer calls instantly in-app or via tap notifications.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Calling Dialog Mockup
          Container(
            padding: EdgeInsets.all(20.w),
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A), // Slate 900
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: const Color(0xFF334155).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withOpacity(0.12),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Avatar Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF22C55E).withOpacity(0.8),
                          width: 2,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 34.r,
                      backgroundColor: const Color(0xFF1E293B),
                      child: Icon(Icons.person, color: const Color(0xFF22C55E), size: 36.sp),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Consultant Calling',
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Incoming Video Consultation...',
                  style: GoogleFonts.manrope(
                    fontSize: 11.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 24.h),
                // Call Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Decline
                    _buildCallActionCircle(
                      icon: Icons.call_end,
                      color: const Color(0xFFEF4444),
                      label: 'Decline',
                    ),
                    // Accept
                    _buildCallActionCircle(
                      icon: Icons.videocam,
                      color: const Color(0xFF22C55E),
                      label: 'Accept',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallActionCircle({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  // Slide 5: Payments & Stripe
  Widget _buildSlidePayment() {
    return _buildSlideContainer(
      title: 'Safe & Fast Payments',
      description: 'Payments are processed securely via Stripe. Add your credit card and only get charged for the minutes you interact with the consultant.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Stylized Payment Card
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fixpair Pay',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    // Simulated chip or logo
                    Container(
                      width: 32.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(Icons.credit_card, color: Colors.white.withOpacity(0.7), size: 16.sp),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                Text(
                  '**** **** **** 4242',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD HOLDER',
                          style: GoogleFonts.manrope(
                            color: Colors.white38,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'JOHN DOE',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXPIRES',
                          style: GoogleFonts.manrope(
                            color: Colors.white38,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '12/28',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Stripe Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, color: const Color(0xFF64748B), size: 14.sp),
              SizedBox(width: 6.w),
              Text(
                'Secured by Stripe Payments',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF64748B),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Base Helper Container for Slides
  Widget _buildSlideContainer({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Expanded(child: Center(child: child)),
          SizedBox(height: 16.h),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D293D),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              description,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
