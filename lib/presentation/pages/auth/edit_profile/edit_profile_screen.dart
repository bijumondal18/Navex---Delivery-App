import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/data/models/state_details.dart';
import 'package:navex/presentation/widgets/app_dropdown_button.dart';
import 'package:navex/presentation/widgets/app_text_field.dart';
import 'package:navex/presentation/widgets/primary_button.dart';
import 'package:navex/presentation/widgets/themed_activity_indicator.dart';

import '../../../bloc/auth_bloc.dart';
import '../../../../core/utils/snackbar_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _zipController;

  bool _isProfileInitialized = false;

  StateDetails? selectedState;
  List<StateDetails> items = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _zipController = TextEditingController();

    context.read<AuthBloc>().add(FetchUserProfileEvent());
    context.read<AuthBloc>().add(FetchStateListEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundGradient(context),
        child: Stack(
          children: [
            _buildBackgroundShapes(context),
            SafeArea(
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is FetchUserProfileStateLoaded &&
                      !_isProfileInitialized) {
                    _nameController.text =
                        state.profileResponse.user?.name ?? '';
                    _emailController.text =
                        state.profileResponse.user?.email ?? '';
                    _phoneController.text =
                        state.profileResponse.user?.driver?.phone ?? '';
                    _addressController.text =
                        state.profileResponse.user?.driver?.address ?? '';
                    _bioController.text =
                        state.profileResponse.user?.driver?.bio ?? '';
                    _zipController.text =
                        state.profileResponse.user?.driver?.zip ?? '';
                    _cityController.text =
                        state.profileResponse.user?.driver?.city ?? '';

                    final stateDetails =
                        state.profileResponse.user?.driver?.stateDetails;
                    if (stateDetails != null) {
                      selectedState = stateDetails;
                    }

                    _isProfileInitialized = true;
                  }

                  if (state is FetchStateListStateLoaded) {
                    setState(() {
                      items = state.stateList;

                      if (selectedState != null && items.isNotEmpty) {
                        final match = items.firstWhere(
                          (item) => item.id == selectedState!.id,
                          orElse: () => items.first,
                        );
                        selectedState = match;
                      }
                    });
                  }
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.kDefaultPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _HeaderRow(
                          onBack: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSizes.kDefaultPadding * 1.4),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.kDefaultPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _GlassSection(
                          title: 'Basic details',
                          subtitle:
                              'Keep your personal information up to date.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                type: AppTextFieldType.text,
                                controller: _nameController,
                                hint: 'Your name',
                              ),
                              const SizedBox(height: AppSizes.kDefaultPadding),
                              AppTextField(
                                type: AppTextFieldType.email,
                                controller: _emailController,
                                readOnly: true,
                                hint: 'Email address',
                              ),
                              const SizedBox(height: AppSizes.kDefaultPadding),
                              AppTextField(
                                type: AppTextFieldType.mobile,
                                controller: _phoneController,
                                hint: 'Phone number',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSizes.kDefaultPadding * 1.2),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.kDefaultPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _GlassSection(
                          title: 'Address & location',
                          subtitle:
                              'Used to help dispatchers route deliveries accurately.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                type: AppTextFieldType.text,
                                controller: _addressController,
                                hint: 'Street address',
                              ),
                              const SizedBox(height: AppSizes.kDefaultPadding),
                              AppDropdownButton<StateDetails>(
                                items: items,
                                selectedItem: selectedState,
                                onChanged: (value) {
                                  setState(() {
                                    selectedState = value;
                                  });
                                },
                                hint: 'Select state',
                                getLabel: (state) =>
                                    state.state?.toString() ?? '',
                              ),
                              const SizedBox(height: AppSizes.kDefaultPadding),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      type: AppTextFieldType.text,
                                      controller: _cityController,
                                      hint: 'City',
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppSizes.kDefaultPadding,
                                  ),
                                  Expanded(
                                    child: AppTextField(
                                      type: AppTextFieldType.mobile,
                                      controller: _zipController,
                                      hint: 'Zip code',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSizes.kDefaultPadding * 1.2),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.kDefaultPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _GlassSection(
                          title: 'About you',
                          subtitle:
                              'Share details about your experience or preferred instructions.',
                          child: AppTextField(
                            type: AppTextFieldType.address,
                            controller: _bioController,
                            hint: 'Short bio',
                            maxLines: 4,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSizes.kDefaultPadding * 1.4),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.kDefaultPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _GlassSection(
                          child: BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state is UpdateProfileStateLoaded) {
                                SnackBarHelper.showSuccess(
                                  state.commonResponse.message ??
                                      'Profile updated successfully',
                                  context: context,
                                );
                                appRouter.go(Screens.profile);
                              }
                              if (state is UpdateProfileStateFailed) {
                                SnackBarHelper.showError(
                                  state.error,
                                  context: context,
                                );
                              }
                            },
                            builder: (context, state) {
                              if (state is UpdateProfileStateLoading) {
                                return const Center(
                                  child: ThemedActivityIndicator(),
                                );
                              }
                              return PrimaryButton(
                                label: 'Save changes',
                                fullWidth: true,
                                onPressed: _submit,
                                size: ButtonSize.lg,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSizes.kDefaultPadding * 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    context.read<AuthBloc>().add(
      UpdateProfileEvent(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        zipCode: _zipController.text.trim(),
        stateId: selectedState?.id.toString(),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.primaryColor.withOpacity(0.95),
          theme.primaryColor.withOpacity(0.85),
          theme.scaffoldBackgroundColor,
        ],
      ),
    );
  }

  Widget _buildBackgroundShapes(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.onPrimary.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -140,
          right: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final VoidCallback onBack;

  const _HeaderRow({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding,
            vertical: AppSizes.kDefaultPadding * 0.9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius * 1.4,
            ),
            color: theme.colorScheme.surface.withOpacity(
              theme.brightness == Brightness.dark ? 0.55 : 0.92,
            ),
            border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.12),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              const SizedBox(width: AppSizes.kDefaultPadding / 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep your Navex account current.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(
                          0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;

  const _GlassSection({this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding * 1.3,
            vertical: AppSizes.kDefaultPadding * 1.2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius * 1.4,
            ),
            color: theme.colorScheme.surface.withOpacity(
              theme.brightness == Brightness.dark ? 0.55 : 0.92,
            ),
            border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.1),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(
                        0.65,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.kDefaultPadding),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
