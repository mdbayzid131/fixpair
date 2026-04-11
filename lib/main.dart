import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  //   await GetStorage.init();

  // Get.put<AppLockService>(AppLockService(), permanent: true);
  // Initialize services here
  // await initServices();
  
  runApp(const MyApp());
}
