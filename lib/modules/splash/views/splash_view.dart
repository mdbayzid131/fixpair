import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: controller.bgColor,
      body: Stack(
        children: [
          // 1. Premium Brand Secondary Blue Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(
                      0xFF003399,
                    ), // Deep Royal Brand Blue (Derived from Secondary)
                    Color(0xFF001133), // Rich Midnight Brand Blue
                  ],
                ),
              ),
            ),
          ),

          // 2. Animated Central Logo and Brand Title
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.85 + (value * 0.15),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The logo asset
                  Image.asset(
                    controller.image,
                    height: 140.h,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                  SizedBox(height: 24.h),

                  // Brand Name / Tagline using Primary Orange
                  Text(
                    'Expertise on Demand',
                    style: GoogleFonts.manrope(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5.w,
                      color: const Color(0xFFFF6B00), // Brand Primary Color
                      shadows: [
                        Shadow(
                          color: const Color(0x66FF6B00),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Animated and Styled Loader at the Bottom using Primary Orange
          Positioned(
            bottom: 80.h,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeIn,
              builder: (context, value, child) {
                return Opacity(opacity: value.clamp(0.0, 1.0), child: child);
              },
              child: Center(
                child: SizedBox(
                  width: 32.w,
                  height: 32.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B00),
                    ), // Primary Orange
                    backgroundColor: Color(
                      0xFF002266,
                    ), // Secondary Blue Background accent
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
