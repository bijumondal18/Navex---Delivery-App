import 'package:flutter/material.dart';
import 'package:navex/core/extensions/status_bar_configs.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_sizes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    statusBarConfig(context: context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(AppSizes.kDefaultPadding),
        children: [
          SafeArea(
            child: Image.asset(
              AppImages.appLogo,
              width: MediaQuery.sizeOf(context).width * 0.23,
              height: MediaQuery.sizeOf(context).height * 0.15,
            ),
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          Text('Welcome Back', style: Theme.of(context).textTheme.titleLarge),
          Text('Please login to continue', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
