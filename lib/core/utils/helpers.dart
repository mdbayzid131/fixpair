import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Helpers {
  // Format time from seconds to mm:ss
  static String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
    // 00:00
  }

  // // Show snackbar
  // static void showSnackbar({
  //   required String title,
  //   required String message,
  //   Color? backgroundColor,
  //   Duration duration = const Duration(seconds: 3),
  // }) {
  //   Get.snackbar(
  //     title,
  //     message,
  //     backgroundColor: backgroundColor,
  //     colorText: Colors.white,
  //     duration: duration,
  //     snackPosition: SnackPosition.BOTTOM,
  //   );
  // }

  // // Show success snackbar
  // static void showSuccessSnackbar(String message) {
  //   showSnackbar(
  //     title: 'Success',
  //     message: message,
  //     backgroundColor: Colors.green,
  //   );
  // }

  // // Show error snackbar
  // static void showErrorSnackbar(String message) {
  //   showSnackbar(title: 'Error', message: message, backgroundColor: Colors.red);
  // }

  //show bebug log
  static void showDebugLog(String message) {
    debugPrint(
      "❌❌❌❌\n❌❌❌❌DEBUG LOG: $message\n❌❌❌❌",
    );
  }

  // Show loading dialog
  static void showLoadingDialog() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }




  static void showCustomSnackBar(
  String? message, {
  bool isError = true,
  bool getXSnackBar = true,
      Duration? duration,

}) {
  if (message != null && message.isNotEmpty) {
    if (getXSnackBar) {
      Get.showSnackbar(
        GetSnackBar(
          messageText: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp, // responsive font size
              fontWeight: FontWeight.w500,
              color: isError ? Colors.red.shade900 : Colors.green.shade900,
            ),
          ),
          duration: duration ?? Duration(seconds: 3),
          snackStyle: SnackStyle.FLOATING,
          margin: EdgeInsets.all(10.w), // responsive margin
          borderRadius: 8.r, // responsive radius
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          backgroundColor: isError
              ? Colors.red.shade100
              : Colors.green.shade100,
          snackPosition: SnackPosition.BOTTOM,
        ),
      );
    } else {
      final context = Get.context;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            dismissDirection: DismissDirection.horizontal,
            margin: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ), // responsive margin
            duration: duration ?? Duration(seconds: 3),
            backgroundColor: isError
                ? Colors.red.shade100
                : Colors.green.shade100,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r), // responsive radius
            ),
            content: Text(
              message,
              style: TextStyle(
                fontSize: 14.sp, // responsive font size
                fontWeight: FontWeight.w500,
                color: isError ? Colors.red.shade900 : Colors.green.shade900,
              ),
            ),
          ),
        );
      }
    }
  }
}

}
