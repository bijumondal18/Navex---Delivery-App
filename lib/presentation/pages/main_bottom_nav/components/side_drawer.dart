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

class SideDrawer extends StatelessWidget {
  final Function(int) onItemTap;

  const SideDrawer({super.key, required this.onItemTap});

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
                                );
                              }
                              return AppCachedImage(
                                width: 96,
                                height: 96,
                                borderRadius: BorderRadius.circular(40),
                                url: '',
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
                                  '',
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
            ListTile(
              onTap: () => onItemTap(0),
              leading: SvgPicture.asset(AppImages.home, width: 24, height: 24),
              title: Text('Home', style: Theme.of(context).textTheme.bodyLarge),
            ),
            ListTile(
              onTap: () => onItemTap(1),
              leading: Image.asset(AppImages.pin, width: 24, height: 24),
              title: Text(
                'Available Routes',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ListTile(
              onTap: () => onItemTap(2),
              leading: Image.asset(AppImages.pin, width: 24, height: 24),
              title: Text(
                'My Accepted Routes',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ListTile(
              onTap: () => onItemTap(3),
              leading: Image.asset(AppImages.pin, width: 24, height: 24),
              title: Text(
                'Route History',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ListTile(
              onTap: () => onItemTap(4),
              leading: SvgPicture.asset(
                AppImages.notifications,
                width: 24,
                height: 24,
              ),
              title: Text(
                'Notifications',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ListTile(
              onTap: () => onItemTap(5),
              leading: SvgPicture.asset(
                AppImages.settings,
                width: 24,
                height: 24,
              ),
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            ListTile(
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
              ),
              title: Text(
                'Logout',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
