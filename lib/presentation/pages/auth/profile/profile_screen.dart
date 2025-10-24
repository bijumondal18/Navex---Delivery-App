import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/presentation/widgets/app_cached_image.dart';
import 'package:navex/presentation/widgets/show_delete_account_dialog.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/screens.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_preference.dart';
import '../../../bloc/auth_bloc.dart';
import '../../../widgets/show_logout_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;

  Future<void> _getUserFullName() async {
    final fullName = await AppPreference.getString(AppPreference.fullName);
    if (!mounted) return;
    setState(() => name = fullName);
  }

  @override
  void initState() {
    super.initState();
    _getUserFullName();
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(FetchUserProfileEvent());
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "Profile",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.white),
        ),
      ),
      body: Column(
        children: [
          // Top Section with Background and Profile
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              children: [
                // Profile Image
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is FetchUserProfileStateLoaded) {
                          return AppCachedImage(
                            url: state.profileResponse.user?.profileImage ?? '',
                            width: 150,
                            height: 150,
                            borderRadius: BorderRadius.circular(
                              AppSizes.cardCornerRadius * 100,
                            ),
                            fit: BoxFit.cover,
                          );
                        }
                        return AppCachedImage(
                          url: '',
                          width: 150,
                          height: 150,
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius * 100,
                          ),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(
                        AppSizes.kDefaultPadding / 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 28,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.kDefaultPadding * 2),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is FetchUserProfileStateLoaded) {
                      return Text(
                        '${state.profileResponse.user?.name}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }
                    return Text(
                      '$name',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // White Card Floating Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding,
              ),
              child: Transform.translate(
                offset: const Offset(0, -50),
                child: Card(
                  elevation: AppSizes.elevationMedium,
                  shadowColor: Theme.of(context).shadowColor.withAlpha(100),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius,
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      _buildProfileOption(
                        icon: Icons.edit_outlined,
                        title: "Edit Profile",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        onTap: () {},
                      ),

                      const Divider(),
                      _buildProfileOption(
                        icon: Icons.info_outline,
                        title: "About Us",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.list_alt_rounded,
                        title: "Terms & Conditions",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        onTap: () {},
                      ),
                      const Divider(),
                      _buildProfileOption(
                        icon: Icons.logout,
                        title: "Logout",
                        onTap: () => showLogoutDialog(context, () async {
                          await AppPreference.clearPreference();
                          appRouter.go(Screens.login);
                        }),
                        color: Colors.red,
                      ),
                      _buildProfileOption(
                        icon: Icons.delete_outline,
                        title: "Delete Account",
                        onTap: () => showDeleteAccountDialog(context, () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Account Deleted Successfully. Please contact with your admin.',
                                style: Theme.of(context).textTheme.labelLarge!
                                    .copyWith(color: AppColors.white),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.errorLight.withAlpha(
                                200,
                              ),
                            ),
                          );
                          // await AppPreference.clearPreference();
                          // appRouter.go(Screens.login);
                        }),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: color),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(120),
      ),
      onTap: onTap,
    );
  }
}
