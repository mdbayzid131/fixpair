import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe with your Publishable Key
  Stripe.publishableKey = "pk_test_51RqgJZGXJvAsdd7omGPG7Z1sPRl3dJb9QY9oCfrl8tSn1StxRIAig3I5xK9hKk1gCVKwSQka5lUi683927AaIoPu00TYnG8Xx";
  await Stripe.instance.applySettings();

  await SystemChrome.setPreferredOrientations([

    DeviceOrientation.portraitUp,
  ]);
  //   await GetStorage.init();

  // Get.put<AppLockService>(AppLockService(), permanent: true);
  // Initialize services here
  // await initServices();
  
  runApp(const MyApp());
}
