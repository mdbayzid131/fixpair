import 'package:fixpair/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomElevatedButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final ButtonStyle? style;
  final Color? backgroundColor;
  final bool isLoading; // <-- নতুন property

  const CustomElevatedButton({
    this.backgroundColor,
    super.key,
    required this.label,
    required this.onPressed,
    this.style,
    this.isLoading = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // loading হলে disable করো
        style:
            style ??
            ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppTheme.primaryColor,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 8,
              shadowColor:
                  backgroundColor?.withValues(alpha: 0.4) ??
                  AppTheme.primaryColor.withValues(alpha: 0.4),
            ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Text(
                label,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}
