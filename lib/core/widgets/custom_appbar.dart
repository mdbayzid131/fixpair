import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_back_button.dart';

/// ===================== CUSTOM APP BAR =====================
/// Factory for creating a consistent, premium AppBar across the app.
class CustomAppBar {
  CustomAppBar._();

  /// Create a styled AppBar with optional leading, actions, and bottom widget
  static AppBar build({
    String? title,
    Widget? titleWidget,
    Widget? leading,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
    bool centerTitle = true,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
    bool showBottomDivider = true,
    Color? backgroundColor,
    double? elevation,
    TextStyle? titleStyle,
  }) {
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && showBackButton) {
      effectiveLeading = Padding(
        padding: EdgeInsets.only(left: 14.w),
        child: CustomBackButton(onTap: onBackPressed),
      );
    }

    return AppBar(
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: effectiveLeading,
      leadingWidth: effectiveLeading != null ? 54.w : null,
      actions: actions != null
          ? [
              ...actions,
              SizedBox(width: 8.w),
            ]
          : null,
      bottom: bottom ??
          (showBottomDivider
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(1.0),
                  child: Container(
                    color: const Color(0xFFE2E8F0).withOpacity(0.6),
                    height: 1.0,
                  ),
                )
              : null),
      title: titleWidget ??
          (title != null
              ? Text(
                  title,
                  style: titleStyle ??
                      GoogleFonts.manrope(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                )
              : null),
    );
  }
}
