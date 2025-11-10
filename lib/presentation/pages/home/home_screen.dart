import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/app_preference.dart';
import 'package:navex/core/utils/date_time_utils.dart';
import 'package:navex/data/models/route.dart';
import 'package:navex/presentation/widgets/app_cached_image.dart';
import 'package:navex/presentation/widgets/custom_switch.dart';
import 'package:navex/presentation/widgets/route_card.dart';
import 'package:navex/presentation/widgets/themed_activity_indicator.dart';

import '../../bloc/auth_bloc.dart';
import '../../bloc/route_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchUpcomingRoutes();
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildAvailabilityCard(context)),
        const SizedBox(width: AppSizes.kDefaultPadding),
        _ActionIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => appRouter.go(Screens.notifications),
        ),
        const SizedBox(width: AppSizes.kDefaultPadding / 1.2),
        _ProfileAvatar(),
      ],
    );
  }

  Widget _buildAvailabilityCard(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final statusText = _isOnline ? 'You are online' : 'You are offline';
    final statusSubtext = _isOnline
        ? 'Customers can assign you new routes.'
        : 'Toggle on when you’re ready to take assignments.';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding * 1.2,
            vertical: AppSizes.kDefaultPadding,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
            color: theme.colorScheme.surface.withOpacity(
              isDark ? 0.55 : 0.9,
            ),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.12),
            ),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_isOnline
                          ? theme.primaryColor
                          : theme.colorScheme.outline)
                      .withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  color: _isOnline
                      ? theme.primaryColor
                      : theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: AppSizes.kDefaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusSubtext,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.kDefaultPadding / 2),
              CustomSwitch(
                value: _isOnline,
                onChanged: (value) {
                  setState(() {
                    _isOnline = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadUserName() async {
    final name = await AppPreference.getString(AppPreference.fullName);
    if (!mounted) return;
    setState(() {
      _userName = name;
    });
  }

  void _fetchUpcomingRoutes() {
    context.read<RouteBloc>().add(
          FetchUpcomingRoutesEvent(
            date: DateTimeUtils.getFormattedPickedDate(DateTime.now()),
          ),
        );
  }

  Future<void> _refreshRoutes() async {
    _fetchUpcomingRoutes();
    await Future.delayed(const Duration(milliseconds: 350));
  }

  String _greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final greeting = _greetingMessage();
    final displayName =
        (_userName?.isNotEmpty ?? false) ? _userName!.split(' ').first : 'there';

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
                color: colorScheme.onPrimary.withOpacity(0.06),
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
                color: colorScheme.primary.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding,
                vertical: AppSizes.kDefaultPadding * 1.2,
              ),
              child: BlocBuilder<RouteBloc, RouteState>(
                builder: (context, state) {
                  final bool isLoading =
                      state is FetchUpcomingRoutesStateLoading;
                  final bool isFailed =
                      state is FetchUpcomingRoutesStateFailed;
                  String? failedMessage;
                  if (state is FetchUpcomingRoutesStateFailed) {
                    failedMessage = state.error;
                  }
                  final List<RouteData> routes =
                      state is FetchUpcomingRoutesStateLoaded
                          ? (state.routeResponse.route ?? [])
                          : <RouteData>[];

                  final int totalRoutes = routes.length;
                  final int totalStops = routes.fold<int>(
                    0,
                    (sum, route) => sum + (route.waypoints?.length ?? 0),
                  );
                  final String nextDeparture = routes.isNotEmpty &&
                          routes.first.startTime != null
                      ? DateTimeUtils.convertToAmPm(
                          '${routes.first.startTime}',
                        )
                      : 'Not scheduled';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: AppSizes.kDefaultPadding * 1.2),
                      _buildHeroCard(
                        context,
                        greeting: '$greeting, $displayName',
                        subtitle:
                            'Here’s what your delivery day looks like today.',
                        date: DateTimeUtils.getFormattedCurrentDate(),
                      ),
                      const SizedBox(height: AppSizes.kDefaultPadding * 1.2),
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              icon: Icons.route_outlined,
                              title: 'Upcoming routes',
                              value: '$totalRoutes',
                              accentColor: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: AppSizes.kDefaultPadding / 1.2),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.schedule_rounded,
                              title: 'Next departure',
                              value: nextDeparture,
                              accentColor:
                                  theme.colorScheme.secondary.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.kDefaultPadding / 1.2),
                      _StatTile(
                        icon: Icons.pin_drop_outlined,
                        title: 'Total stops today',
                        value: '$totalStops',
                        accentColor: theme.colorScheme.tertiary,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: AppSizes.kDefaultPadding * 1.5),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: isLoading
                              ? const Center(
                                  child: ThemedActivityIndicator(),
                                )
                              : isFailed
                                  ? _buildErrorState(
                                      context,
                                      failedMessage ?? 'Something went wrong',
                                    )
                                  : routes.isEmpty
                                      ? _buildEmptyState(context)
                                      : RefreshIndicator(
                                          onRefresh: _refreshRoutes,
                                          color: theme.primaryColor,
                                          child: ListView.separated(
                                            physics:
                                                const BouncingScrollPhysics(
                                              parent:
                                                  AlwaysScrollableScrollPhysics(),
                                            ),
                                            padding: const EdgeInsets.only(
                                              left: 2,
                                              right: 2,
                                              bottom:
                                                  AppSizes.kDefaultPadding * 5,
                                            ),
                                            itemCount: routes.length,
                                            separatorBuilder: (_, __) =>
                                                const SizedBox(
                                              height:
                                                  AppSizes.kDefaultPadding / 1.5,
                                            ),
                                            itemBuilder: (context, index) =>
                                                RouteCard(
                                              route: routes[index],
                                            ),
                                          ),
                                        ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String greeting,
    required String subtitle,
    required String date,
  }) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding * 1.4,
            vertical: AppSizes.kDefaultPadding * 1.4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius * 1.4,
            ),
            color: theme.colorScheme.surface.withOpacity(
              isDark ? 0.55 : 0.9,
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.16),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.kDefaultPadding,
                  vertical: AppSizes.kDefaultPadding / 1.4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppSizes.cardCornerRadius * 1.2,
                  ),
                  color: theme.primaryColor.withOpacity(0.12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 42,
            color: theme.primaryColor.withOpacity(0.75),
          ),
          const SizedBox(height: 16),
          Text(
            'You’re all set!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No routes are scheduled right now. We’ll notify you when something changes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 42,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load routes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _fetchUpcomingRoutes,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: theme.colorScheme.surface.withOpacity(
            isDark ? 0.45 : 0.85,
          ),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: theme.primaryColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? imageUrl;
        if (state is FetchUserProfileStateLoaded) {
          imageUrl = state.profileResponse.user?.profileImage;
        }
        return GestureDetector(
          onTap: () => appRouter.go(Screens.profile),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
                  color: Theme.of(context).colorScheme.surface.withOpacity(
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.45
                            : 0.85,
                      ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.12),
                  ),
                ),
                child: AppCachedImage(
                  url: imageUrl ?? '',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  circular: true,
                  borderWidth: 0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;
  final bool isFullWidth;

  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kDefaultPadding * 1.1,
        vertical: AppSizes.kDefaultPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.2),
        color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 0.88),
        border: Border.all(
          color: accentColor.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: AppSizes.kDefaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
