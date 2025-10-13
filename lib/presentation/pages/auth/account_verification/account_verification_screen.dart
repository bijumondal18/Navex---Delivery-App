import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navex/presentation/widgets/password_reset_successful_dialog.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/screens.dart';
import '../../../../core/resources/app_images.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../bloc/auth_bloc.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class AccountVerificationScreen extends StatefulWidget {
  final String registeredEmail;

  const AccountVerificationScreen({super.key, required this.registeredEmail});

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

    BlocProvider.of<AuthBloc>(context).add(
      ResetPasswordEvent(
        email: widget.registeredEmail,
        otp: _otpController.text.trim().toString(),
        password: _newPasswordController.text.trim().toString(),
        confirmPassword: _confirmPasswordController.text.trim().toString(),
      ),
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
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is ResetPasswordStateLoaded) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                // prevent tap-out dismiss
                                builder: (context) {
                                  Future.delayed(
                                    const Duration(milliseconds: 3000),
                                    () {
                                      appRouter.go(Screens.login);
                                    },
                                  );
                                  return const PasswordResetSuccessfulDialog();
                                },
                              );
                            }
                            if (state is ResetPasswordStateFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.error,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(color: AppColors.white),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            if (state is ResetPasswordStateLoading) {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                            return PrimaryButton(
                              label: 'Submit',
                              size: ButtonSize.lg,
                              onPressed: () => _submit(),
                              fullWidth: true,
                              isLoading: false,
                            );
                          },
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
