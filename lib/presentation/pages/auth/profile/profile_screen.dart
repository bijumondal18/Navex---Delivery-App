import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/presentation/widgets/app_cached_image.dart';
import 'package:navex/presentation/widgets/show_delete_account_dialog.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/screens.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/app_preference.dart';
import '../../../bloc/auth_bloc.dart';
import '../../../widgets/show_image_picker_bottom_sheet.dart';
import '../../../widgets/show_logout_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;

  final ImagePicker _picker = ImagePicker();

  File? pickedFile;

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
            height: MediaQuery.of(context).size.height * 0.25,
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
                          return pickedFile == null
                              ? AppCachedImage(
                                  url:
                                      state
                                          .profileResponse
                                          .user
                                          ?.profileImage ??
                                      '',
                                  width: 120,
                                  height: 120,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.cardCornerRadius * 100,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 122,
                                  height: 122,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.file(
                                      pickedFile!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                        }
                        return AppCachedImage(
                          url: '',
                          width: 120,
                          height: 120,
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius * 100,
                          ),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        _showImagePickerBottomSheet(context: context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                          AppSizes.kDefaultPadding / 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryDark,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 22,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.kDefaultPadding),
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
              child: Padding(
                padding: const EdgeInsets.only(top: AppSizes.kDefaultPadding),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.kDefaultPadding / 2,
                      ),
                      children: [
                        _buildProfileOption(
                          icon: Icons.edit_outlined,
                          title: "Edit Profile",
                          onTap: () => appRouter.push(Screens.editProfile),
                        ),
                        // _buildProfileOption(
                        //   icon: Icons.lock_outline,
                        //   title: "Change Password",
                        //   onTap: () {},
                        // ),
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

  void _showImagePickerBottomSheet({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardCornerRadius),
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
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(
                      bottom: AppSizes.kDefaultPadding / 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardCornerRadius,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt_outlined,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  title: Text(
                    'Take a photo',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () async {
                    final XFile? file = await _picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (file != null) {
                      setState(() => pickedFile = File(file.path));
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library_outlined,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                  title: Text(
                    'Choose from gallery',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onTap: () async {
                    final XFile? file = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (file != null) {
                      setState(() => pickedFile = File(file.path));
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
