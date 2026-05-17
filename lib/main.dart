import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Stripe with your Publishable Key
  Stripe.publishableKey =
      // "pk_test_51RqgJZGXJvAsdd7omGPG7Z1sPRl3dJb9QY9oCfrl8tSn1StxRIAig3I5xK9hKk1gCVKwSQka5lUi683927AaIoPu00TYnG8Xx"; sakhaat bhai 
      // Stripe.publishableKey =
      //     "pk_test_51TY3kL393GULNOfIRDSscdl5o4vLyqbLXuNmig7h86kUjDc42NDcoAGgvoA983mtVrixx5k6VsE2U4vXMIm3lzAO00e8905EIO";client
      Stripe.publishableKey =
          "pk_test_51RzPsELje7aworqDsz57lVuTN8DGxH6isrNX2EDOxMmkZfYBciS7ckmSGwSRc6MEg1oOt2sl9vnV1QSJfvMUTzDs00mHWdBTLM";
  await Stripe.instance.applySettings();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  //   await GetStorage.init();

  // Get.put<AppLockService>(AppLockService(), permanent: true);
  // Initialize services here
  // await initServices();

  runApp(const MyApp());
}
