import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/presentation/bloc/auth_bloc.dart';

import '../../../../core/resources/app_images.dart';
import '../../../../core/extensions/status_bar_configs.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/themed_activity_indicator.dart';

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
    statusBarConfig(context: context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.95),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.12,
                    child: SvgPicture.asset(
                      AppImages.topOval,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.08,
                    child: SvgPicture.asset(
                      AppImages.sideOval,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.kDefaultPadding,
                      isKeyboardVisible
                          ? AppSizes.kDefaultPadding
                          : AppSizes.kDefaultPadding * 2,
                      AppSizes.kDefaultPadding,
                      AppSizes.kDefaultPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: isKeyboardVisible
                              ? const SizedBox.shrink()
                              : Column(
                                  key: const ValueKey('forgot_header'),
                                  children: [
                                    Hero(
                                      tag: 'navex-logo',
                                      child: Image.asset(
                                        AppImages.appLogo,
                                        width: mediaQuery.size.width * 0.24,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Forgot your password?',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'We’ll send a secure code to your registered email so you can reset access in minutes.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onPrimary.withOpacity(0.82),
                                      ),
                                    ),
                                    const SizedBox(height: AppSizes.kDefaultPadding * 1.4),
                                  ],
                                ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius * 1.4,
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.kDefaultPadding * 1.2,
                                vertical: AppSizes.kDefaultPadding * 1.3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.cardCornerRadius * 1.4,
                                ),
                                color: theme.colorScheme.surface.withOpacity(
                                  theme.brightness == Brightness.dark ? 0.5 : 0.88,
                                ),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    blurRadius: 28,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reset password',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Enter the email linked to your Navex account.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.72),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.kDefaultPadding * 1.2),
                                  AppTextField(
                                    type: AppTextFieldType.email,
                                    controller: _emailController,
                                    textInputAction: TextInputAction.done,
                                    hint: 'Email address',
                                    required: true,
                                  ),
                                  const SizedBox(height: AppSizes.kDefaultPadding * 1.4),
                                  BlocConsumer<AuthBloc, AuthState>(
                                    listener: (context, state) {
                                      if (state is ForgotPasswordStateLoaded) {
                                        SnackBarHelper.showInfo(
                                          state.forgotPasswordResponse.message ??
                                              'OTP has been sent to your email.',
                                          context: context,
                                        );
                                        appRouter.push(
                                          Screens.accountVerification,
                                          extra: _emailController.text.trim().toString(),
                                        );
                                      }
                                      if (state is ForgotPasswordStateFailed) {
                                        SnackBarHelper.showError(
                                          state.error,
                                          context: context,
                                        );
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state is ForgotPasswordStateLoading) {
                                        return const Center(
                                          child: ThemedActivityIndicator(),
                                        );
                                      }
                                      return PrimaryButton(
                                        label: 'Send reset code',
                                        size: ButtonSize.lg,
                                        onPressed: _submit,
                                        fullWidth: true,
                                        isLoading: false,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: AppSizes.kDefaultPadding),
                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: () => appRouter.pop(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: theme.primaryColor,
                                      ),
                                      child: const Text('Back to login'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
