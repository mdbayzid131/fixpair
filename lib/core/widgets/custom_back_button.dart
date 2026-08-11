import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.iconSize,
    this.containerSize,
    this.onTap,
  });

  final double? iconSize;
  final double? containerSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = containerSize ?? 36.w;
    return Center(
      child: InkWell(
        onTap: onTap ?? () => Get.back(),
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: iconSize ?? 16.sp,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ),
    );
  }
}
