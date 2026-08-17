import 'package:fixpair/config/themes/app_system_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/core/services/app_lock_service.dart';

import 'app.dart';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   SystemChrome.setSystemUIOverlayStyle(
    AppSystemUi.light,
  );

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Stripe with Publishable Key from .env
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';



  await Stripe.instance.applySettings();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await GetStorage.init();

  // Load saved language, default to German ('de_DE')
  final savedLang = await StorageService.getString(StorageConstants.language);
  Locale initialLocale;
  if (savedLang == 'en') {
    initialLocale = const Locale('en', 'US');
  } else {
    initialLocale = const Locale('de', 'DE');
  }

  Get.put<AppLockService>(AppLockService(), permanent: true);

  runApp(MyApp(initialLocale: initialLocale));
}
