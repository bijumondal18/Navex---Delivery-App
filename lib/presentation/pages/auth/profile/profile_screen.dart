import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/data/models/user.dart';
import 'package:navex/presentation/widgets/app_cached_image.dart';
import 'package:navex/presentation/widgets/show_delete_account_dialog.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/screens.dart';
import '../../../../core/utils/app_preference.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../bloc/auth_bloc.dart';
import '../../../widgets/show_logout_dialog.dart';
import '../../../widgets/themed_activity_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  File? pickedFile;
  bool _isUploadingProfileImage = false;

  User? _cachedUser;
  String? _cachedName;
  String? _cachedEmail;

  @override
  void initState() {
    super.initState();
    _loadCachedIdentity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(FetchUserProfileEvent());
    });
  }

  Future<void> _loadCachedIdentity() async {
    final savedName = await AppPreference.getString(AppPreference.fullName);
    final savedEmail = await AppPreference.getString(AppPreference.email);
    if (!mounted) return;
    setState(() {
      _cachedName = savedName;
      _cachedEmail = savedEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is FetchUserProfileStateLoaded) {
          setState(() {
            _cachedUser = state.profileResponse.user;
            _cachedName = state.profileResponse.user?.name ?? _cachedName;
            _cachedEmail = state.profileResponse.user?.email ?? _cachedEmail;
          });
        } else if (state is FetchUserProfileStateFailed) {
          SnackBarHelper.showError(state.error, context: context);
        } else if (_isUploadingProfileImage &&
            state is UpdateProfileStateLoaded) {
          setState(() {
            _isUploadingProfileImage = false;
            pickedFile = null;
          });
          final message =
              state.commonResponse.message ?? 'Profile updated successfully';
          SnackBarHelper.showSuccess(message, context: context);
        } else if (_isUploadingProfileImage &&
            state is UpdateProfileStateFailed) {
          setState(() {
            _isUploadingProfileImage = false;
            pickedFile = null;
          });
          SnackBarHelper.showError(state.error, context: context);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final bool isInitialLoading =
              state is FetchUserProfileStateLoading && _cachedUser == null;
          final bool isRefreshing =
              state is FetchUserProfileStateLoading && _cachedUser != null;

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              title: Text(
                'Profile',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.white),
              ),
            ),
            body: Stack(
              children: [
                _buildGradientBackground(context),
                if (isInitialLoading)
                  const Center(child: ThemedActivityIndicator())
                else
                  SafeArea(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<AuthBloc>().add(FetchUserProfileEvent());
                        await Future.delayed(const Duration(milliseconds: 350));
                      },
                      color: Theme.of(context).primaryColor,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          AppSizes.kDefaultPadding,
                          AppSizes.kDefaultPadding * 1.4,
                          AppSizes.kDefaultPadding,
                          AppSizes.kDefaultPadding * 2.5 +
                              MediaQuery.of(context).padding.bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isRefreshing) ...[
                              const LinearProgressIndicator(minHeight: 3),
                              const SizedBox(height: AppSizes.kDefaultPadding),
                            ],
                            _buildProfileOverview(context),
                            const SizedBox(
                              height: AppSizes.kDefaultPadding * 1.5,
                            ),
                            _buildMetaSection(context),
                            const SizedBox(
                              height: AppSizes.kDefaultPadding * 1.5,
                            ),
                            _buildActionSection(context),
                            const SizedBox(
                              height: AppSizes.kDefaultPadding * 1.2,
                            ),
                            _buildDangerZone(context),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColor.withOpacity(0.95),
            theme.primaryColor.withOpacity(0.85),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Stack(
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
      ),
    );
  }

  Widget _buildProfileOverview(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final String displayName = (_cachedName?.trim().isNotEmpty ?? false)
        ? _cachedName!.trim()
        : 'Driver';
    final String email = (_cachedEmail?.trim().isNotEmpty ?? false)
        ? _cachedEmail!.trim()
        : 'No email';
    final String role =
        _cachedUser?.role?.toString().replaceAll('_', ' ').toUpperCase() ??
        'DRIVER';
    final bool isEmailVerified =
        (_cachedUser?.emailVerifiedAt?.toString().isNotEmpty ?? false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding * 1.4,
            vertical: AppSizes.kDefaultPadding * 1.6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius * 1.6,
            ),
            color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 0.9),
            border: Border.all(color: theme.primaryColor.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.16),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _buildAvatar(context),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () =>
                          _showImagePickerBottomSheet(context: context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _PillChip(
                    label: role,
                    icon: Icons.badge_outlined,
                    color: theme.primaryColor,
                  ),
                  _PillChip(
                    label: isEmailVerified ? 'VERIFIED EMAIL' : 'EMAIL PENDING',
                    icon: isEmailVerified
                        ? Icons.verified_rounded
                        : Icons.mark_email_unread_outlined,
                    color: isEmailVerified
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final double size = 120;

    Widget avatar;
    if (pickedFile != null) {
      avatar = ClipOval(
        child: Image.file(
          pickedFile!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      avatar = AppCachedImage(
        url: _cachedUser?.profileImage?.toString() ?? '',
        width: size,
        height: size,
        circular: true,
        borderWidth: 2,
        fit: BoxFit.cover,
      );
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.8),
              ],
            ),
          ),
          child: ClipOval(child: avatar),
        ),
        if (_isUploadingProfileImage)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: ThemedActivityIndicator(radius: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetaSection(BuildContext context) {
    final theme = Theme.of(context);
    final metaItems = <_ProfileMetaData>[
      if (_cachedEmail != null && _cachedEmail!.trim().isNotEmpty)
        _ProfileMetaData(
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: _cachedEmail!,
        ),
      if (_cachedUser?.driver?.phone != null &&
          _cachedUser!.driver!.phone.toString().trim().isNotEmpty)
        _ProfileMetaData(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: _cachedUser!.driver!.phone.toString(),
        ),
      if (_cachedUser?.driver?.pharmacy?.name != null &&
          _cachedUser!.driver!.pharmacy!.name.toString().trim().isNotEmpty)
        _ProfileMetaData(
          icon: Icons.local_hospital_outlined,
          label: 'Assigned pharmacy',
          value: _cachedUser!.driver!.pharmacy!.name.toString(),
        ),
      if (_cachedUser?.driver?.pharmacy?.pharmacyKey != null &&
          _cachedUser!.driver!.pharmacy!.pharmacyKey
              .toString()
              .trim()
              .isNotEmpty)
        _ProfileMetaData(
          icon: Icons.vpn_key_outlined,
          label: 'Pharmacy key',
          value: _cachedUser!.driver!.pharmacy!.pharmacyKey.toString(),
        ),
      if (_cachedUser?.driver?.city != null &&
          _cachedUser!.driver!.city.toString().trim().isNotEmpty)
        _ProfileMetaData(
          icon: Icons.location_city_outlined,
          label: 'City',
          value: _cachedUser!.driver!.city.toString(),
        ),
    ];

    if (metaItems.isEmpty) return const SizedBox.shrink();

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          Column(
            children: metaItems
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSizes.kDefaultPadding,
                    ),
                    child: _ProfileMetaTile(data: item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    final actions = [
      _ProfileActionData(
        icon: Icons.edit_outlined,
        label: 'Edit profile',
        onTap: () => appRouter.push(Screens.editProfile),
      ),
      _ProfileActionData(
        icon: Icons.info_outline_rounded,
        label: 'About Navex',
        onTap: () {},
      ),
      _ProfileActionData(
        icon: Icons.description_outlined,
        label: 'Terms & conditions',
        onTap: () {},
      ),
      _ProfileActionData(
        icon: Icons.privacy_tip_outlined,
        label: 'Privacy policy',
        onTap: () {},
      ),
    ];

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions
            .map(
              (action) => Column(
                children: [
                  _ProfileActionTile(action: action),
                  if (action != actions.last)
                    Divider(
                      color: Theme.of(context).dividerColor.withOpacity(0.6),
                    ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassPanel(
      tintColor: theme.colorScheme.error.withOpacity(0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger zone',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          _ProfileActionTile(
            action: _ProfileActionData(
              icon: Icons.logout_rounded,
              label: 'Sign out of Navex',
              foregroundColor: theme.colorScheme.error,
              onTap: () => showLogoutDialog(context, () async {
                await AppPreference.clearPreference();
                appRouter.go(Screens.login);
              }),
            ),
          ),
          Divider(color: theme.colorScheme.error.withOpacity(0.3)),
          _ProfileActionTile(
            action: _ProfileActionData(
              icon: Icons.delete_outline_rounded,
              label: 'Delete account',
              foregroundColor: theme.colorScheme.error,
              onTap: () => showDeleteAccountDialog(context, () async {
                SnackBarHelper.showWarning(
                  'Account deleted successfully. Please contact your admin for support.',
                  context: context,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadProfileImage(File file) {
    setState(() {
      pickedFile = file;
      _isUploadingProfileImage = true;
    });
    context.read<AuthBloc>().add(UpdateProfileEvent(profileImage: file));
  }

  void _showImagePickerBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardCornerRadius * 1.1),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSizes.kDefaultPadding,
            ),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(
                      bottom: AppSizes.kDefaultPadding * 1.2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardCornerRadius,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Take a photo',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () async {
                    final XFile? file = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 90,
                    );
                    if (file != null) {
                      _uploadProfileImage(File(file.path));
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Choose from gallery',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () async {
                    final XFile? file = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 90,
                    );
                    if (file != null) {
                      _uploadProfileImage(File(file.path));
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final Color? tintColor;

  const _GlassPanel({required this.child, this.tintColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding * 1.3,
            vertical: AppSizes.kDefaultPadding * 1.2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius * 1.4,
            ),
            color:
                (tintColor ??
                theme.colorScheme.surface.withOpacity(isDark ? 0.5 : 0.92)),
            border: Border.all(color: theme.primaryColor.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _PillChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetaData {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileMetaData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _ProfileMetaTile extends StatelessWidget {
  final _ProfileMetaData data;

  const _ProfileMetaTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(data.icon, color: theme.primaryColor, size: 20),
        ),
        const SizedBox(width: AppSizes.kDefaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileActionData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? foregroundColor;

  const _ProfileActionData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foregroundColor,
  });
}

class _ProfileActionTile extends StatelessWidget {
  final _ProfileActionData action;

  const _ProfileActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = action.foregroundColor ?? theme.textTheme.bodyLarge?.color;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(action.icon, color: color),
      title: Text(
        action.label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: color?.withOpacity(0.6),
      ),
      onTap: action.onTap,
    );
  }
}
