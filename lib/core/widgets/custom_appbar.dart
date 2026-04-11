import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomWidgets{
  static AppBar customAppBar({required String title, Widget? leading, List<Widget>? action}) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.4,
            color: Color(0xff222222)
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(0xff333333),
        size: 20.sp,
      ),
      leading: leading,

      actions: action,
    );
  }

}
