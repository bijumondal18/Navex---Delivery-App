import 'package:flutter/material.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/utils/app_preference.dart';

import '../../../core/extensions/status_bar_configs.dart';
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
    Future.delayed(const Duration(milliseconds: 500),(){
      _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    final token = await AppPreference.getString(AppPreference.token);
    final isLoggedIn = await AppPreference.getBool(AppPreference.isLoggedIn);

    if (token != null && isLoggedIn == true) {
      appRouter.go(Screens.main);
    } else {
      appRouter.go(Screens.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    statusBarConfig(context: context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.colorScheme.primaryContainer.withOpacity(0.9),
                  theme.colorScheme.secondary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            left: -mediaQuery.size.width * 0.25,
            top: -mediaQuery.size.width * 0.35,
            child: Container(
              width: mediaQuery.size.width * 0.9,
              height: mediaQuery.size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.onPrimary.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: -mediaQuery.size.width * 0.35,
            bottom: -mediaQuery.size.width * 0.2,
            child: Container(
              width: mediaQuery.size.width,
              height: mediaQuery.size.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.onPrimary.withOpacity(0.04),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: Column(
                children: [
                  const Spacer(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                          tag: 'navex-logo',
                          child: Image.asset(
                            AppImages.splashLogo,
                            fit: BoxFit.contain,
                            width: mediaQuery.size.width * 0.45,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Smarter navigation for modern pharmacies',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(strokeWidth: 3.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Setting things up for you…',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      AppImages.splashBottom,
                      fit: BoxFit.cover,
                      width: mediaQuery.size.width,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
