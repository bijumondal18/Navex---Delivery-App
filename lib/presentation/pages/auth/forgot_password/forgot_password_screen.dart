import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/presentation/bloc/auth_bloc.dart';

import '../../../../core/resources/app_images.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late TextEditingController _emailController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) return;
    BlocProvider.of<AuthBloc>(
      context,
    ).add(ForgotPasswordEvent(email: _emailController.text.trim().toString()));
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
                          'Forgot Password',
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
                          hint: 'Registered email id',
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
                            if (state is ForgotPasswordStateLoaded) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.forgotPasswordResponse.message ??
                                        'OTP has been sent to your email.',
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
                              appRouter.push(
                                Screens.accountVerification,
                                extra: _emailController.text.trim().toString(),
                              );
                            }
                            if (state is ForgotPasswordStateFailed) {
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
                            if (state is ForgotPasswordStateLoading) {
                              return const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            }
                            return PrimaryButton(
                              label: 'Next',
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
