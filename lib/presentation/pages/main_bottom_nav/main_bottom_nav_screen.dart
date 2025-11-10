import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';

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
      iconData: Icons.space_dashboard_rounded,
    ),
    _NavItemData(
      label: 'Available routes',
      route: Screens.availableRoutes,
      iconData: Icons.map_rounded,
    ),
    _NavItemData(
      label: 'Accepted routes',
      route: Screens.acceptedRoutes,
      iconData: Icons.task_alt_rounded,
    ),
    _NavItemData(
      label: 'Route history',
      route: Screens.routeHistory,
      iconData: Icons.history_rounded,
    ),
    _NavItemData(
      label: 'Profile',
      route: Screens.profile,
      iconData: Icons.person_rounded,
    ),
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith(Screens.profile)) return 4;
    if (location.startsWith(Screens.routeHistory)) return 3;
    if (location.startsWith(Screens.acceptedRoutes)) return 2;
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
        body: widget.child,
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: _navBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 0.9),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 18,
                  offset: const Offset(0, -6),
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
    final bool isDark = theme.brightness == Brightness.dark;

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
                ? activeColor.withOpacity(0.12)
                : theme.colorScheme.surface.withOpacity(isDark ? 0.08 : 0.05),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? activeColor.withOpacity(0.22)
                  : Colors.transparent,
            ),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [activeColor, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected
                  ? null
                  : theme.colorScheme.surface.withOpacity(isDark ? 0.38 : 0.75),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : theme.primaryColor.withOpacity(0.08),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                data.iconData,
                size: 22,
                color: isSelected ? Colors.white : inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final String route;
  final IconData iconData;

  const _NavItemData({
    required this.label,
    required this.route,
    required this.iconData,
  });
}
