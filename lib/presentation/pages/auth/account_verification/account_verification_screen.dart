import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navex/presentation/widgets/password_reset_successful_dialog.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      builder: (context) => PasswordResetSuccessfulDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
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
                    padding: const EdgeInsets.only(
                      top: AppSizes.kDefaultPadding,
                    ),
                    child: Image.asset(
                      AppImages.appLogo,
                      width: MediaQuery.sizeOf(context).width * 0.23,
                      height: MediaQuery.sizeOf(context).height * 0.15,
                    ),
                  ),
                ),

                Card(
                  margin: const EdgeInsets.only(top: AppSizes.kDefaultPadding),
                  color: Theme.of(context).cardColor,
                  shadowColor: Theme.of(context).shadowColor,
                  elevation: AppSizes.elevationSmall,
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
                          type: AppTextFieldType.otp,
                          controller: _otpController,
                          textInputAction: TextInputAction.next,
                          hint: 'OTP',
                          required: true,
                          maxLength: 6,
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
                          textInputAction: TextInputAction.next,
                          hint: 'New Password',
                          required: true,
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
                          required: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSizes.kDefaultPadding,
                          right: AppSizes.kDefaultPadding,
                          top: AppSizes.kDefaultPadding * 2,
                          bottom: AppSizes.kDefaultPadding * 2,
                        ),
                        child: PrimaryButton(
                          label: 'Submit',
                          size: ButtonSize.lg,
                          onPressed: () => _submit(),
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
      ),
    );
  }
}
