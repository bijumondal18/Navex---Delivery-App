import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/presentation/pages/main_bottom_nav/components/side_drawer.dart';
import 'package:navex/presentation/widgets/app_cached_image.dart';
import 'package:navex/presentation/widgets/custom_switch.dart';

import '../../widgets/show_exit_confirm_dialog.dart';
import '../available_routes/available_routes_screen.dart';
import '../home/home_screen.dart';
import '../my_accepted_routes/my_accepted_routes_screen.dart';
import '../notifications/notifications_screen.dart';
import '../route_history/route_history_screen.dart';
import '../settings/settings_screen.dart';

class MainBottomNavScreen extends StatefulWidget {
  final Widget child;

  const MainBottomNavScreen({super.key, required this.child});

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  bool _isOnline = false;

  void _onDrawerItemTap(int index) async {
    // 1) Close the drawer
    Navigator.of(context, rootNavigator: true).pop();

    // Let the drawer animation finish (~250–300ms feels right)
    await Future.delayed(const Duration(milliseconds: 280));

    // 2) After the drawer is closed, navigate
    final target = switch (index) {
      0 => Screens.main,
      1 => Screens.availableRoutes,
      2 => Screens.acceptedRoutes,
      3 => Screens.routeHistory,
      4 => Screens.notifications,
      5 => Screens.settings,
      _ => Screens.main,
    };

    // 3) After the drawer is closed, always navigate from the root GoRouter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.go(
        target,
      );
    });
  }

  Future<bool> _onWillPop() async {
    // 1) If drawer is open, close it and don't exit
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState?.isDrawerOpen ?? false) {
      scaffoldState?.closeDrawer();
      return false;
    }

    // 2) If current navigator can pop (e.g., you're on /trip/123), pop it
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return false;
    }

    // 3) Ask to exit
    final shouldExit = await showExitConfirmDialog(context) ?? false;
    if (shouldExit) {
      // Best practice on Android; on iOS it's discouraged to programmatically exit
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      }
      // On iOS: just return true and let the system handle it (usually does nothing)
    }
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'Navex',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            CustomSwitch(
              value: _isOnline,
              onChanged: (value) {
                setState(() {
                  _isOnline = value;
                });
              },
            ),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none_rounded, size: 24),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.kDefaultPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppSizes.cardCornerRadius / 1.5,
                ),
                child: AppCachedImage(
                  url:
                      'https://t4.ftcdn.net/jpg/04/31/64/75/360_F_431647519_usrbQ8Z983hTYe8zgA7t1XVc5fEtqcpa.jpg',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        drawer: SideDrawer(onItemTap: _onDrawerItemTap),
        body: widget.child,
      ),
    );
  }
}
