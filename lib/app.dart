import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/bindings/initial_binding.dart';
import 'package:fixpair/core/localization/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xffffffff),
              scrolledUnderElevation: 0,
            ),
            scaffoldBackgroundColor: Color(0xffffffff),
          ),
          initialRoute: AppRoutes.SPLASH,
          getPages: pages,
          initialBinding: InitialBinding(),
          translations: AppTranslations(),
          locale: initialLocale,
          fallbackLocale: const Locale('en', 'US'),
        );
      },
    );
  }
}
