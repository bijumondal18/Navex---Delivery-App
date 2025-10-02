import 'dart:io';

import 'package:flutter/material.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';

import '../../../core/extensions/status_bar_configs.dart';
import '../../../service/force_update/version_check_service.dart';
import '../../widgets/show_force_update_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // final VersionCheckService _versionService = VersionCheckService();


  // Future<void> _checkVersion() async {
  //   final info = await _versionService.checkForUpdate(
  //     isAndroid: Platform.isAndroid,
  //   );
  //
  //   if (info == null) return;
  //
  //   if (info["forceUpdate"]) {
  //     if (mounted) {
  //       showUpdateDialog(context, forceUpdate: true, updateUrl: info["url"]);
  //     }
  //   } else if (info["optionalUpdate"]) {
  //     if (mounted) {
  //       showUpdateDialog(context, forceUpdate: false, updateUrl: info["url"]);
  //     }
  //   } else {
  //     // Continue to main screen
  //     Future.delayed(const Duration(milliseconds: 500), () {
  //       appRouter.go(Screens.login);
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // _checkVersion();
    Future.delayed(const Duration(milliseconds: 500), () {
      appRouter.go(Screens.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    statusBarConfig(context: context);
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
