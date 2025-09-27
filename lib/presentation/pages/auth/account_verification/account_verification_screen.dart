import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navex/presentation/widgets/password_reset_successfull_dialog.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/screens.dart';
import '../../../../core/resources/app_images.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({super.key});

  @override
  State<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  late TextEditingController _otpController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        'Account Verification',
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
                        type: AppTextFieldType.mobile,
                        controller: _otpController,
                        textInputAction: TextInputAction.done,
                        hint: 'OTP',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSizes.kDefaultPadding,
                        right: AppSizes.kDefaultPadding,
                        top: AppSizes.kDefaultPadding,
                      ),
                      child: AppTextField(
                        type: AppTextFieldType.password,
                        controller: _newPasswordController,
                        textInputAction: TextInputAction.done,
                        hint: 'New Password',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSizes.kDefaultPadding,
                        right: AppSizes.kDefaultPadding,
                        top: AppSizes.kDefaultPadding,
                      ),
                      child: AppTextField(
                        type: AppTextFieldType.password,
                        controller: _confirmPasswordController,
                        textInputAction: TextInputAction.done,
                        hint: 'Confirm Password',
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
                        label: 'Submit',
                        size: ButtonSize.lg,
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) =>
                              PasswordResetSuccessfullDialog(),
                        ),
                        fullWidth: true,
                        isLoading: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
