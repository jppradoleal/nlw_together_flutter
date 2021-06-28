import 'package:flutter/material.dart';
import 'package:nlw_together/modules/barcod_scanner/barcode_scanner_page.dart';
import 'package:nlw_together/modules/home/home_page.dart';
import 'package:nlw_together/modules/login/login_page.dart';
import 'package:nlw_together/modules/splash/splash_page.dart';
import 'package:nlw_together/shared/themes/app_colors.dart';

class AppWidget extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        primarySwatch: Colors.orange,
      ),
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => SplashPage(),
        "/home": (context) => HomePage(),
        "/login": (context) => LoginPage(),
        "/barcode_scanner": (context) => BarcodeScannerPage()
      },
    );
  }
}
