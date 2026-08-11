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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   SystemChrome.setSystemUIOverlayStyle(
    AppSystemUi.light,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // Initialize Stripe with your Publishable Key
  Stripe.publishableKey =
      "pk_test_51RzPsELje7aworqDsz57lVuTN8DGxH6isrNX2EDOxMmkZfYBciS7ckmSGwSRc6MEg1oOt2sl9vnV1QSJfvMUTzDs00mHWdBTLM"; //nayem (Publishable Key)
  // Stripe.publishableKey =
  //     "pk_test_51RqgJZGXJvAsdd7omGPG7Z1sPRl3dJb9QY9oCfrl8tSn1StxRIAig3I5xK9hKk1gCVKwSQka5lUi683927AaIoPu00TYnG8Xx6"; //sakhaat bhai
  // Stripe.publishableKey =
  //     "pk_test_51TY3kL393GULNOfIRDSscdl5o4vLyqbLXuNmig7h86kUjDc42NDcoAGgvoA983mtVrixx5k6VsE2U4vXMIm3lzAO00e8905EIO"; //client


  await Stripe.instance.applySettings();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await GetStorage.init();

  // Load saved language
  final savedLang = await StorageService.getString(StorageConstants.language);
  Locale initialLocale;
  if (savedLang == 'de') {
    initialLocale = const Locale('de', 'DE');
  } else {
    initialLocale = const Locale('en', 'US');
  }

  Get.put<AppLockService>(AppLockService(), permanent: true);

  runApp(MyApp(initialLocale: initialLocale));
}
