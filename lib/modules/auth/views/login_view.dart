import 'package:fixpair/config/constants/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:fixpair/core/widgets/custom_elevated_button.dart';
import 'package:fixpair/core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                    Image.asset(ImagePaths.appLogo, height: 80.h),
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
                        'Expert advice across Germany.\nWhenever you need it.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE0EFFF),
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),

                    // 2. Welcome Section
                    Text(
                      'Welcome back',
                      style: GoogleFonts.manrope(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Log in to continue your consultations.',
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    SizedBox(height: 24.h),

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

                    Obx(
                      () => CustomTextField(
                        controller: controller.passwordController,
                        hintText: 'Password',
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
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 20.sp,
                          ),
                        ),
                        validator: Validators.password,
                      ),
                    ),

                    // 5. Options Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Remember me',
                              style: GoogleFonts.manrope(
                                fontSize: 13.sp,
                                color: const Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: controller.goToForgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.manrope(
                              fontSize: 13.sp,
                              color: const Color(0xFF0066FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // 6. Log In Button
                    Obx(
                      () => CustomElevatedButton(
                        label: 'Log In',
                        onPressed: controller.login,
                        isLoading: controller.isLoading.value,
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
                            'OR CONTINUE WITH',
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
                            onTap: () {},
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildSocialButton(
                            icon: Icons
                                .apple, // Using Material Icon for Apple if image not available
                            label: 'Apple',
                            onTap: () {},
                            isSvg: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),

                    // 9. Sign up Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.goToRegister,
                            child: Text(
                              'Sign up',
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
                    SizedBox(height: 32.h),
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
}
