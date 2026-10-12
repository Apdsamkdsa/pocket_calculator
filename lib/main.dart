import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_calculator/screens/splash_page.dart';
import 'package:pocket_calculator/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PocketCalculatorApp());
}

class PocketCalculatorApp extends StatelessWidget {
  const PocketCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Calculator',
      debugShowCheckedModeBanner: false,
      theme: pocketTheme(),
      home: const SplashPage(),
    );
  }
}
