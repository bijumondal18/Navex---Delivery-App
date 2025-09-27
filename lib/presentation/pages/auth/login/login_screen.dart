import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navex/core/extensions/status_bar_configs.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/presentation/widgets/app_text_field.dart';
import 'package:navex/presentation/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pharmacyKeyController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  bool _cbRememberMe = false;

  @override
  Widget build(BuildContext context) {
    statusBarConfig(context: context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          SvgPicture.asset(AppImages.sideOval, fit: BoxFit.cover),
          SvgPicture.asset(AppImages.topOval, fit: BoxFit.cover),

          ListView(
            padding: EdgeInsets.all(AppSizes.kDefaultPadding),
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSizes.kDefaultPadding),
                  child: Image.asset(
                    AppImages.appLogo,
                    width: MediaQuery.sizeOf(context).width * 0.23,
                    height: MediaQuery.sizeOf(context).height * 0.15,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: AppSizes.kDefaultPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius,
                  ),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 0.6,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.kDefaultPadding,
                      ),
                      child: Text(
                        'Log In',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 3,
                      margin: EdgeInsets.symmetric(
                        vertical: AppSizes.kDefaultPadding / 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardCornerRadius,
                        ),
                      ),
                    ),
                    Divider(color: Theme.of(context).dividerColor),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSizes.kDefaultPadding,
                        right: AppSizes.kDefaultPadding,
                        top: AppSizes.kDefaultPadding,
                      ),
                      child: AppTextField(
                        type: AppTextFieldType.email,
                        controller: _emailController,
                        textInputAction: TextInputAction.done,
                        hint: 'Email Id',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSizes.kDefaultPadding,
                        right: AppSizes.kDefaultPadding,
                        top: AppSizes.kDefaultPadding,
                      ),
                      child: AppTextField(
                        type: AppTextFieldType.text,
                        controller: _pharmacyKeyController,
                        textInputAction: TextInputAction.done,
                        hint: 'Pharmacy Key',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSizes.kDefaultPadding,
                        right: AppSizes.kDefaultPadding,
                        top: AppSizes.kDefaultPadding,
                      ),
                      child: AppTextField(
                        type: AppTextFieldType.mobile,
                        controller: _mobileController,
                        textInputAction: TextInputAction.done,
                        hint: 'Mobile Number',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSizes.kDefaultPadding,
                        right: AppSizes.kDefaultPadding,
                        top: AppSizes.kDefaultPadding * 2,
                        bottom: AppSizes.kDefaultPadding,
                      ),
                      child: PrimaryButton(
                        label: 'Log In',
                        size: ButtonSize.lg,
                        onPressed: () {},
                        fullWidth: true,
                        isLoading: false,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.kDefaultPadding / 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: AppSizes.kDefaultPadding / 2),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 0,
                      children: [
                        SizedBox(
                          width: 24.0,
                          height: 24.0,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(
                                AppSizes.cardCornerRadius / 2,
                              ),
                            ),
                            side: BorderSide(
                              width: 0.6,
                              color: Theme.of(context).dividerColor,
                            ),
                            value: _cbRememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _cbRememberMe = value ?? false;
                              });
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _cbRememberMe = !_cbRememberMe;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0.5, left: 4.0),
                            child: Text(
                              'Remember me',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => appRouter.push(Screens.forgotPassword),
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
