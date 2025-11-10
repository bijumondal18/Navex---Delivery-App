import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/presentation/pages/auth/account_verification/account_verification_screen.dart';
import 'package:navex/presentation/pages/auth/edit_profile/edit_profile_screen.dart';
import 'package:navex/presentation/pages/auth/forgot_password/forgot_password_screen.dart';
import 'package:navex/presentation/pages/available_routes/available_routes_screen.dart';
import 'package:navex/presentation/pages/in_route/delivery_outcome_screen.dart';
import 'package:navex/presentation/pages/in_route/in_route_screen.dart';
import 'package:navex/presentation/pages/my_accepted_routes/my_accepted_routes_screen.dart';
import 'package:navex/presentation/pages/notifications/notifications_screen.dart';
import 'package:navex/presentation/pages/route_history/route_history_screen.dart';
import 'package:navex/presentation/pages/settings/settings_screen.dart';
import 'package:navex/presentation/pages/trip_details/trip_details_screen.dart';

import '../../presentation/pages/auth/login/login_screen.dart';
import '../../presentation/pages/auth/profile/profile_screen.dart';
import '../../presentation/pages/home/home_screen.dart';
import '../../presentation/pages/main_bottom_nav/main_bottom_nav_screen.dart';
import '../../presentation/pages/spalsh/splash_screen.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: Screens.splash,
  routes: [
    GoRoute(
      path: Screens.splash,
      name: 'splash',
      pageBuilder: (context, state) =>
          _buildAnimatedPage(state, SplashScreen()),
    ),
    GoRoute(
      path: Screens.login,
      name: 'login',
      pageBuilder: (context, state) =>
          _buildAnimatedPage(state, LoginScreen()),
    ),
    GoRoute(
      path: Screens.forgotPassword,
      name: 'forgot_password',
      pageBuilder: (context, state) =>
          _buildAnimatedPage(state, ForgotPasswordScreen()),
    ),
    GoRoute(
      path: Screens.accountVerification,
      name: 'account_verification',
      pageBuilder: (context, state) {
        final flag = state.extra as String;
        return _buildAnimatedPage(
          state,
          AccountVerificationScreen(registeredEmail: flag),
        );
      },
    ),
    GoRoute(
      path: Screens.editProfile,
      name: 'edit_profile',
      pageBuilder: (context, state) =>
          _buildAnimatedPage(state, EditProfileScreen()),
    ),
    GoRoute(
      path: Screens.deliveryOutcome,
      name: 'delivery_outcome',
      pageBuilder: (context, state) {
        final args = state.extra as DeliveryOutcomeArgs;
        return _buildAnimatedPage(
          state,
          DeliveryOutcomeScreen(
            optionKey: args.optionKey,
            title: args.title,
          ),
        );
      },
    ),
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => MainBottomNavScreen(
        child: child,
        state: state,
      ),
      routes: [
        GoRoute(
          path: Screens.main,
          name: 'main',
          pageBuilder: (_, state) =>
              _buildAnimatedPage(state, const HomeScreen()),
          routes: [
            GoRoute(
              path: 'trip/:id/details',
              name: Screens.tripDetails,
              pageBuilder: (_, state) => _buildAnimatedPage(
                state,
                TripDetailsScreen(
                  routeId: '${state.pathParameters['id']}',
                ),
              ),
            ),
            GoRoute(
              path: 'trip/:id/in_route',
              name: Screens.inRoute,
              pageBuilder: (_, state) => _buildAnimatedPage(
                state,
                InRouteScreen(
                  routeId: '${state.pathParameters['id']}',
                ),
              ),
            ),
          ],
        ),
        GoRoute(
          path: Screens.availableRoutes,
          name: 'available_routes',
          pageBuilder: (_, state) =>
              _buildAnimatedPage(state, AvailableRoutesScreen()),
        ),
        GoRoute(
          path: Screens.acceptedRoutes,
          name: 'accepted_routes',
          pageBuilder: (_, state) =>
              _buildAnimatedPage(state, MyAcceptedRoutesScreen()),
        ),
        GoRoute(
          path: Screens.routeHistory,
          name: 'route_history',
          pageBuilder: (_, state) =>
              _buildAnimatedPage(state, RouteHistoryScreen()),
        ),
        GoRoute(
          path: Screens.profile,
          name: 'profile',
          pageBuilder: (_, state) =>
              _buildAnimatedPage(state, const ProfileScreen()),
        ),
        GoRoute(
          path: Screens.settings,
          name: 'settings',
          pageBuilder: (_, state) =>
              _buildAnimatedPage(state, SettingsScreen()),
        ),
        GoRoute(
          path: Screens.notifications,
          name: 'notifications',
          pageBuilder: (_, state) =>
              _buildAnimatedPage(state, NotificationsScreen()),
        ),
      ],
    ),

    // GoRoute(
    //   path: Screens.editProfileField,
    //   name: 'edit_profile_field',
    //   pageBuilder: (context, state) {
    //     final flag = state.extra as String;
    //     return CustomTransitionPage(
    //       key: state.pageKey,
    //       child: EditFieldScreen(flag: flag),
    //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //         final tween = Tween<Offset>(
    //           begin: const Offset(0, 1), // Bottom of the screen
    //           end: Offset.zero,
    //         ).chain(CurveTween(curve: Curves.easeInOut));
    //
    //         return SlideTransition(
    //           position: animation.drive(tween),
    //           child: child,
    //         );
    //       },
    //     );
    //   },
    // ),
  ],
);

CustomTransitionPage<void> _buildAnimatedPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    child: child,
    transitionsBuilder:
        (context, animation, secondaryAnimation, pageChild) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curvedAnimation);

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: pageChild,
        ),
      );
    },
  );
}
