import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:navex/core/extensions/status_bar_configs.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/snackbar_helper.dart';
import 'package:navex/presentation/widgets/app_text_field.dart';
import 'package:navex/presentation/widgets/primary_button.dart';
import 'package:navex/presentation/widgets/themed_activity_indicator.dart';

import '../../../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _pharmacyKeyController;
  late TextEditingController _passwordController;

  bool _cbRememberMe = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _pharmacyKeyController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pharmacyKeyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    BlocProvider.of<AuthBloc>(context).add(
      LoginSubmittedEvent(
        email: _emailController.text.trim().toString(),
        password: _passwordController.text.trim().toString(),
        pharmacyKey: _pharmacyKeyController.text.trim().toString(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    statusBarConfig(context: context);
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;

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
                      theme.primaryColor.withOpacity(0.94),
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
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: isKeyboardVisible
                              ? const SizedBox.shrink()
                              : Column(
                                  key: const ValueKey('login_header'),
                                  children: [
                                    Hero(
                                      tag: 'navex-logo',
                                      child: Image.asset(
                                        AppImages.appLogo,
                                        width: mediaQuery.size.width * 0.26,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Welcome back!',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Log in to track deliveries, manage inventory, and stay ahead of demand.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onPrimary.withOpacity(0.82),
                                      ),
                                    ),
                                    const SizedBox(height: AppSizes.kDefaultPadding * 1.5),
                                  ],
                                ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.kDefaultPadding * 1.2,
                                vertical: AppSizes.kDefaultPadding * 1.4,
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
                                    color: theme.colorScheme.primary.withOpacity(0.12),
                                    blurRadius: 32,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Account Access',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Enter your credentials to continue',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.kDefaultPadding * 1.2),
                                  AppTextField(
                                    type: AppTextFieldType.email,
                                    controller: _emailController,
                                    textInputAction: TextInputAction.next,
                                    hint: 'Email address',
                                    required: true,
                                  ),
                                  const SizedBox(height: AppSizes.kDefaultPadding),
                                  AppTextField(
                                    type: AppTextFieldType.text,
                                    controller: _pharmacyKeyController,
                                    textInputAction: TextInputAction.next,
                                    hint: 'Pharmacy key',
                                    required: true,
                                  ),
                                  const SizedBox(height: AppSizes.kDefaultPadding),
                                  AppTextField(
                                    type: AppTextFieldType.password,
                                    controller: _passwordController,
                                    textInputAction: TextInputAction.done,
                                    hint: 'Password',
                                    required: true,
                                  ),
                                  const SizedBox(height: AppSizes.kDefaultPadding * 1.3),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: _cbRememberMe,
                                          activeColor: theme.primaryColor,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          onChanged: (value) {
                                            setState(() {
                                              _cbRememberMe = value ?? false;
                                            });
                                          },
                                          side: BorderSide(
                                            width: 0.8,
                                            color: theme.dividerColor.withOpacity(0.6),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppSizes.cardCornerRadius / 2.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _cbRememberMe = !_cbRememberMe;
                                          });
                                        },
                                        child: Text(
                                          'Remember me',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => appRouter.push(Screens.forgotPassword),
                                        style: TextButton.styleFrom(
                                          foregroundColor: theme.primaryColor,
                                        ),
                                        child: const Text('Forgot password?'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSizes.kDefaultPadding * 1.4),
                                  BlocConsumer<AuthBloc, AuthState>(
                                    listener: (context, state) {
                                      if (state is LoginStateLoaded) {
                                        appRouter.go(Screens.main);
                                      }
                                      if (state is LoginStateFailed) {
                                        SnackBarHelper.showError(
                                          state.error,
                                          context: context,
                                        );
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state is LoginStateLoading) {
                                        return const Center(
                                          child: ThemedActivityIndicator(),
                                        );
                                      }
                                      return PrimaryButton(
                                        label: 'Continue',
                                        size: ButtonSize.lg,
                                        onPressed: _submit,
                                        fullWidth: true,
                                        isLoading: false,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!isKeyboardVisible) ...[
                          const SizedBox(height: AppSizes.kDefaultPadding * 2),
                          Text(
                            'Need help? Reach out to your Navex admin or contact support@navex.com',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
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
