import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/app_preference.dart';
import 'package:navex/presentation/widgets/app_cached_image.dart';
import 'package:navex/presentation/widgets/show_logout_dialog.dart';

import '../../../bloc/auth_bloc.dart';

class SideDrawer extends StatefulWidget {
  final Function(int) onItemTap;
  final int selectedIndex;

  const SideDrawer({
    super.key,
    required this.onItemTap,
    required this.selectedIndex,
  });

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
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
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.65,
      child: Drawer(
        shape: RoundedRectangleBorder(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height * 0.27,
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Stack(
                children: [
                  SvgPicture.asset(AppImages.sideOval, fit: BoxFit.cover),
                  SvgPicture.asset(AppImages.topOval, fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.kDefaultPadding,
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: AppSizes.kDefaultPadding,
                        children: [
                          const SizedBox(height: AppSizes.kDefaultPadding),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is FetchUserProfileStateLoaded) {
                                return AppCachedImage(
                                  width: 96,
                                  height: 96,
                                  borderRadius: BorderRadius.circular(40),
                                  url:
                                      state
                                          .profileResponse
                                          .user
                                          ?.profileImage ??
                                      '',
                                  circular: true,
                                  borderWidth: 2,
                                );
                              }
                              return AppCachedImage(
                                width: 96,
                                height: 96,
                                borderRadius: BorderRadius.circular(40),
                                url: '',
                                circular: true,
                                borderWidth: 2,
                              );
                            },
                          ),
                          Expanded(
                            child: BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                if (state is FetchUserProfileStateLoaded) {
                                  return Text(
                                    '${state.profileResponse.user?.name}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white,
                                        ),
                                  );
                                }
                                return Text(
                                  '$name',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.kDefaultPadding),
            _buildMenuTile(
              index: 0,
              label: 'Home',
              iconBuilder: (isSelected) => SvgPicture.asset(
                AppImages.home,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _menuIconColor(isSelected),
                  BlendMode.srcIn,
                ),
              ),
            ),
            _buildMenuTile(
              index: 1,
              label: 'Available Routes',
              iconBuilder: (isSelected) => Image.asset(
                AppImages.pin,
                width: 24,
                height: 24,
                color: _menuIconColor(isSelected),
              ),
            ),
            _buildMenuTile(
              index: 2,
              label: 'My Accepted Routes',
              iconBuilder: (isSelected) => Image.asset(
                AppImages.pin,
                width: 24,
                height: 24,
                color: _menuIconColor(isSelected),
              ),
            ),
            _buildMenuTile(
              index: 3,
              label: 'Route History',
              iconBuilder: (isSelected) => Image.asset(
                AppImages.pin,
                width: 24,
                height: 24,
                color: _menuIconColor(isSelected),
              ),
            ),
            _buildMenuTile(
              index: 4,
              label: 'Notifications',
              iconBuilder: (isSelected) => SvgPicture.asset(
                AppImages.notifications,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _menuIconColor(isSelected),
                  BlendMode.srcIn,
                ),
              ),
            ),
            // ListTile(
            //   onTap: () => onItemTap(5),
            //   leading: SvgPicture.asset(
            //     AppImages.settings,
            //     width: 24,
            //     height: 24,
            //   ),
            //   title: Text(
            //     'Settings',
            //     style: Theme.of(context).textTheme.bodyLarge,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding / 2,
              ),
              child: ListTile(
                onTap: () {
                  appRouter.pop();
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (context.mounted) {
                      showLogoutDialog(context, () async {
                        await AppPreference.clearPreference();
                        appRouter.go(Screens.login);
                      });
                    }
                  });
                },
                leading: SvgPicture.asset(
                  AppImages.logout,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.errorDark.withAlpha(200),
                    BlendMode.srcIn,
                  ),
                ),
                title: Text(
                  'Logout',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.errorDark),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required int index,
    required String label,
    required Widget Function(bool isSelected) iconBuilder,
  }) {
    final bool isSelected = widget.selectedIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kDefaultPadding / 2,
      ),
      child: ListTile(
        onTap: () => widget.onItemTap(index),
        leading: iconBuilder(isSelected),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface.withOpacity(0.85),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Color _menuIconColor(bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isSelected) {
      return colorScheme.onPrimary;
    }
    return colorScheme.onSurface.withOpacity(0.7);
  }
}
