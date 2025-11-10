import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../bloc/auth_bloc.dart';
import '../../widgets/show_exit_confirm_dialog.dart';

class MainBottomNavScreen extends StatefulWidget {
  final Widget child;
  final GoRouterState state;

  const MainBottomNavScreen({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  State<MainBottomNavScreen> createState() => _MainBottomNavScreenState();
}

class _MainBottomNavScreenState extends State<MainBottomNavScreen> {
  bool _hasRequestedProfile = false;
  int _selectedIndex = 0;

  static const double _navBarHeight = 82;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasRequestedProfile && mounted) {
        context.read<AuthBloc>().add(FetchUserProfileEvent());
        _hasRequestedProfile = true;
      }
      _syncIndexWithRoute();
    });
  }

  @override
  void didUpdateWidget(covariant MainBottomNavScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.uri != widget.state.uri) {
      _syncIndexWithRoute();
    }
  }

  void _syncIndexWithRoute() {
    final location = widget.state.uri.path;
    final newIndex = _indexFromLocation(location);
    if (_selectedIndex != newIndex && mounted) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  final List<_NavItemData> _navItems = const [
    _NavItemData(
      label: 'Home',
      route: Screens.main,
      iconType: _NavIconType.svg,
      assetPath: AppImages.home,
    ),
    _NavItemData(
      label: 'Available Routes',
      route: Screens.availableRoutes,
      iconType: _NavIconType.raster,
      assetPath: AppImages.pin,
    ),
    _NavItemData(
      label: 'Route History',
      route: Screens.routeHistory,
      iconType: _NavIconType.svg,
      assetPath: AppImages.clockGreen,
    ),
    _NavItemData(
      label: 'Profile',
      route: Screens.profile,
      iconType: _NavIconType.icon,
      iconData: Icons.person_outline,
    ),
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith(Screens.profile)) return 3;
    if (location.startsWith(Screens.routeHistory)) return 2;
    if (location.startsWith(Screens.availableRoutes)) return 1;
    return 0;
  }

  void _onNavItemTap(int index) {
    if (index == _selectedIndex) return;
    final route = _navItems[index].route;
    setState(() {
      _selectedIndex = index;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appRouter.go(route);
    });
  }

  Future<bool> _onWillPop() async {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return false;
    }

    if (_selectedIndex != 0) {
      _onNavItemTap(0);
      return false;
    }

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
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: _navBarHeight + 32),
                child: widget.child,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16 + MediaQuery.of(context).padding.bottom,
              child: _buildBottomNavBar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: _navBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 0.9),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.15),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _navItems.length,
              (index) => Expanded(
                child: _NavItem(
                  data: _navItems[index],
                  isSelected: index == _selectedIndex,
                  onTap: () => _onNavItemTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color activeColor = theme.primaryColor;
    final Color inactiveColor = theme.colorScheme.onSurface.withOpacity(0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(isSelected ? activeColor : inactiveColor),
              // const SizedBox(height: 6),
              // AnimatedDefaultTextStyle(
              //   duration: const Duration(milliseconds: 200),
              //   curve: Curves.easeOut,
              //   style: theme.textTheme.bodySmall!.copyWith(
              //     fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              //     color: isSelected ? activeColor : inactiveColor,
              //     letterSpacing: 0.2,
              //   ),
              //   child: Text(data.label),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    switch (data.iconType) {
      case _NavIconType.svg:
        return SvgPicture.asset(
          data.assetPath!,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        );
      case _NavIconType.raster:
        return Image.asset(
          data.assetPath!,
          width: 24,
          height: 24,
          color: color,
        );
      case _NavIconType.icon:
        return Icon(data.iconData, size: 24, color: color);
    }
  }
}

enum _NavIconType { svg, raster, icon }

class _NavItemData {
  final String label;
  final String route;
  final _NavIconType iconType;
  final String? assetPath;
  final IconData? iconData;

  const _NavItemData({
    required this.label,
    required this.route,
    required this.iconType,
    this.assetPath,
    this.iconData,
  }) : assert(
         (iconType == _NavIconType.icon && iconData != null) ||
             (iconType != _NavIconType.icon && assetPath != null),
         'Provide an iconData for icon type or an assetPath for asset-based types.',
       );
}
