import 'package:fixpair/config/constants/image_paths.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:fixpair/core/widgets/custom_elevated_button.dart';
import 'package:fixpair/core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Blue Gradient Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 30.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF9799B4), Color(0xFF80A4DC)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.r),
                    bottomRight: Radius.circular(40.r),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Image.asset(ImagePaths.appLogoWithoutBg, height: 80.h),
                    SizedBox(height: 12.h),
                    Text(
                      'Fixpair',
                      style: GoogleFonts.manrope(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        'Expert advice across Germany.\nWhenever you need it.'.tr,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE0EFFF),
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 28.h),

                    // 2. Create Section
                    Text(
                      'Create an account'.tr,
                      style: GoogleFonts.manrope(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign up to get started.'.tr,
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    SizedBox(height: 24.h),

                    // 4. Input Fields
                    CustomTextField(
                      controller: controller.nameController,
                      hintText: 'Full Name'.tr,
                      validator: Validators.name,
                      label: '',
                      isLabelVisible: false,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: const Color(0xFF9CA3AF),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    CustomTextField(
                      controller: controller.emailController,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      label: '',
                      isLabelVisible: false,
                      fillColor: const Color(0xFFF8FAFC),
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        color: const Color(0xFF9CA3AF),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Date of Birth (Must be 18+)
                    GestureDetector(
                      onTap: () => controller.pickDateOfBirth(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: controller.dobController,
                          hintText: 'Date of Birth (Must be 18+)'.tr,
                          label: '',
                          isLabelVisible: false,
                          fillColor: const Color(0xFFF8FAFC),
                          prefixIcon: Icon(
                            Icons.cake_outlined,
                            color: const Color(0xFF9CA3AF),
                            size: 20.sp,
                          ),
                          suffixIcon: Icon(
                            Icons.calendar_today_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 18.sp,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please select your date of birth'.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Obx(() {
                      if (controller.dobError.value.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 6.h, left: 4.w),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 14.sp,
                              color: const Color(0xFFEF4444),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                controller.dobError.value,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 16.h),

                    Obx(
                      () => CustomTextField(
                        controller: controller.passwordController,
                        focusNode: controller.passwordFocusNode,
                        hintText: 'Password'.tr,
                        onChanged: controller.validatePasswordRules,
                        obscureText: !controller.isPasswordVisible.value,
                        label: '',
                        isLabelVisible: false,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: const Color(0xFF9CA3AF),
                          size: 20.sp,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: controller.togglePasswordVisibility,
                          child: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF9CA3AF),
                            size: 20.sp,
                          ),
                        ),
                        validator: (value) {
                          return Validators.password(
                            value,
                            minLength: 8,
                            requireDigit: true,
                            requireUppercase: true,
                            requireLowercase: true,
                            requireSpecialChar: true,
                          );
                        },
                      ),
                    ),

                    // Compact Animated Password Requirements Hint Container
                    Obx(() {
                      final showHints =
                          (controller.isPasswordFocused.value ||
                              controller.passwordController.text.isNotEmpty) &&
                          !controller.areAllPasswordRulesMet;

                      return AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: showHints
                            ? Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Password must contain:'.tr,
                                      style: GoogleFonts.manrope(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildRequirementRow(
                                                controller.hasMinLength.value,
                                                'At least 8 characters'.tr,
                                              ),
                                              SizedBox(height: 4.h),
                                              _buildRequirementRow(
                                                controller.hasUppercase.value,
                                                'One uppercase letter'.tr,
                                              ),
                                              SizedBox(height: 4.h),
                                              _buildRequirementRow(
                                                controller.hasSpecial.value,
                                                'One special character'.tr,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildRequirementRow(
                                                controller.hasLowercase.value,
                                                'One lowercase letter'.tr,
                                              ),
                                              SizedBox(height: 4.h),
                                              _buildRequirementRow(
                                                controller.hasDigit.value,
                                                'One number'.tr,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      );
                    }),
                    SizedBox(height: 16.h),

                    Obx(
                      () => CustomTextField(
                        controller: controller.confirmPasswordController,
                        hintText: 'Confirm Password'.tr,
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        label: '',
                        isLabelVisible: false,
                        fillColor: const Color(0xFFF8FAFC),
                        prefixIcon: Icon(
                          Icons.lock_reset_rounded,
                          color: const Color(0xFF9CA3AF),
                          size: 20.sp,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: controller.toggleConfirmPasswordVisibility,
                          child: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF9CA3AF),
                            size: 20.sp,
                          ),
                        ),
                        validator: (v) {
                          if (v != controller.passwordController.text) {
                            return 'Passwords do not match'.tr;
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // 5a. Age 18+ Confirmation Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: Checkbox(
                              value: controller.isAgeConfirmed.value,
                              onChanged: (v) =>
                                  controller.isAgeConfirmed.value = v ?? false,
                              activeColor: const Color(0xFFFF6B00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.isAgeConfirmed.value =
                                !controller.isAgeConfirmed.value,
                            child: Text(
                              'I confirm that I am at least 18 years old.'.tr,
                              style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF374151),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // 5b. Terms & Conditions + Liability Disclaimer + Privacy Policy
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: Checkbox(
                              value: controller.agreeToTerms.value,
                              onChanged: (v) =>
                                  controller.agreeToTerms.value = v ?? false,
                              activeColor: const Color(0xFFFF6B00),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                color: const Color(0xFF374151),
                              ),
                              children: [
                                TextSpan(text: 'I agree to the '.tr),
                                TextSpan(
                                  text: 'Terms & Conditions'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF0066FF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.toNamed(AppRoutes.TERMS_CONDITIONS);
                                    },
                                ),
                                const TextSpan(text: ', '),
                                TextSpan(
                                  text: 'Liability Disclaimer'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF0066FF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.toNamed(AppRoutes.TERMS_CONDITIONS);
                                    },
                                ),
                                TextSpan(text: ' and '.tr),
                                TextSpan(
                                  text: 'Privacy Policy (GDPR)'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF0066FF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.toNamed(AppRoutes.PRIVACY_POLICY);
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 6. Sign Up Button
                    Obx(
                      () => CustomElevatedButton(
                        label: 'Sign Up'.tr,
                        onPressed: (controller.agreeToTerms.value &&
                                controller.isAgeConfirmed.value)
                            ? controller.register
                            : null,
                        isLoading: controller.isLoading.value,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          minimumSize: Size(double.infinity, 56.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFFFF6B00).withOpacity(0.4),
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 7. Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE5E7EB)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            'OR CONTINUE WITH'.tr,
                            style: GoogleFonts.manrope(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9CA3AF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE5E7EB)),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 8. Social Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton(
                            icon: ImagePaths.googleIcon,
                            label: 'Google',
                            onTap: controller.loginWithGoogle,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildSocialButton(
                            icon: Icons.apple,
                            label: 'Apple',
                            onTap: controller.loginWithApple,
                            isSvg: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // 9. Login Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ".tr,
                            style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.goToLogin,
                            child: Text(
                              'Log in'.tr,
                              style: GoogleFonts.manrope(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0066FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    dynamic icon,
    required String label,
    required VoidCallback onTap,
    bool isSvg = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSvg)
              SvgPicture.asset(icon as String, width: 22.w, height: 22.h)
            else
              Icon(icon as IconData, size: 24.sp, color: Colors.black),
            SizedBox(width: 10.w),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D293D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(bool isMet, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isMet ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          size: 13.sp,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 11.sp,
              fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
              color: isMet ? const Color(0xFF10B981) : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
