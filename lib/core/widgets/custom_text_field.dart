import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// ===================== CUSTOM TEXT FIELD =====================
/// A styled text field with optional label, icons, and validation.
/// Follows the app's design system with consistent border radius and fill color.
class CustomTextField extends StatelessWidget {
  final String hintText;
  final String? label;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLabelVisible;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.label,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.isLabelVisible = true,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.fillColor,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── LABEL ───
        if (isLabelVisible && label != null)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              label!,
              style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),

        // ─── TEXT FIELD ───
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          style: GoogleFonts.manrope(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          decoration: _buildDecoration(),
        ),
      ],
    );
  }

  InputDecoration _buildDecoration() {
    final borderRadius = BorderRadius.circular(16.r);
    final border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide.none,
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.arimo(
        fontSize: 17.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xff8E8E93),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 14.h,
        horizontal: 16.w,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? const Color(0xffF2F2F7),
      border: border,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
      focusedErrorBorder: border,
      counterText: '',
      errorStyle: GoogleFonts.arimo(
        fontSize: 11.sp,
        color: Colors.red,
      ),
    );
  }
}
