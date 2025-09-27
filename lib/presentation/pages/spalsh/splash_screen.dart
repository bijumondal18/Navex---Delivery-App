import 'package:flutter/material.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      appRouter.go(Screens.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        children: [
          Spacer(),
          Spacer(),
          Image.asset(
            AppImages.splashLogo,
            fit: BoxFit.contain,
            width: MediaQuery.sizeOf(context).width * 0.5,
          ),
          Spacer(),
          Image.asset(
            AppImages.splashBottom,
            fit: BoxFit.cover,
            width: MediaQuery.sizeOf(context).width,
          ),
        ],
      ),
    );
  }
}
