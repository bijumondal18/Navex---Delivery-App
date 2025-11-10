import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/data/models/route.dart';
import 'package:navex/data/repositories/route_repository.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_picker_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../bloc/route_bloc.dart';
import '../../widgets/route_card.dart';
import '../../widgets/themed_activity_indicator.dart';

class MyAcceptedRoutesScreen extends StatefulWidget {
  const MyAcceptedRoutesScreen({super.key});

  @override
  State<MyAcceptedRoutesScreen> createState() => _MyAcceptedRoutesScreenState();
}

class _MyAcceptedRoutesScreenState extends State<MyAcceptedRoutesScreen> {
  DateTime? _selectedDate;
  late final RouteBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RouteBloc(RouteRepository())
      ..add(
        FetchAcceptedRoutesEvent(
          date: DateTimeUtils.getFormattedPickedDate(DateTime.now()),
        ),
      );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _openCalendar() async {
    final pickedDate = await showAppDatePicker(
      context: context,
      barrierDismissible: false,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
      _bloc.add(
        FetchAcceptedRoutesEvent(
          date: DateTimeUtils.getFormattedPickedDate(pickedDate),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    final targetDate = _selectedDate ?? DateTime.now();
    _bloc.add(
      FetchAcceptedRoutesEvent(
        date: DateTimeUtils.getFormattedPickedDate(targetDate),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 320));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Container(
        decoration: _buildBackgroundGradient(context),
        child: Stack(
          children: [
            _buildBackgroundShapes(context),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.kDefaultPadding,
                  AppSizes.kDefaultPadding * 1.3,
                  AppSizes.kDefaultPadding,
                  AppSizes.kDefaultPadding,
                ),
                child: BlocBuilder<RouteBloc, RouteState>(
                  builder: (context, state) {
                    final bool isLoading =
                        state is FetchAcceptedRoutesStateLoading;
                    final bool isFailed =
                        state is FetchAcceptedRoutesStateFailed;
                    String? failureMessage;
                    if (state is FetchAcceptedRoutesStateFailed) {
                      failureMessage = state.error;
                    }
                    final List<RouteData> routes =
                        state is FetchAcceptedRoutesStateLoaded
                            ? (state.routeResponse.route ?? [])
                            : <RouteData>[];

                    final int totalRoutes = routes.length;
                    final int totalStops = routes.fold<int>(
                      0,
                      (sum, route) => sum + (route.waypoints?.length ?? 0),
                    );
                    final int activeRoutes = routes.where((route) {
                      final status =
                          (route.status ?? '').toString().toLowerCase();
                      final bool hasStarted = (route.tripStartTime != null &&
                          '${route.tripStartTime}'.trim().isNotEmpty);
                      final bool hasEnded = (route.tripEndTime != null &&
                          '${route.tripEndTime}'.trim().isNotEmpty);
                      return status.contains('in_route') ||
                          status.contains('in-progress') ||
                          status.contains('inprogress') ||
                          (hasStarted && !hasEnded);
                    }).length;
                    String nextDeparture = 'Not scheduled';
                    for (final route in routes) {
                      final startTime = route.startTime;
                      if (startTime != null &&
                          '$startTime'.trim().isNotEmpty) {
                        nextDeparture =
                            DateTimeUtils.convertToAmPm('$startTime');
                        break;
                      }
                    }

                    if (isLoading) {
                      return const Center(child: ThemedActivityIndicator());
                    }

                    final slivers = <Widget>[
                      SliverToBoxAdapter(
                        child: _AcceptedHeroHeader(
                          title: 'Accepted routes',
                          subtitle:
                              'Manage deliveries you’ve already confirmed and stay ahead of schedule.',
                          dateLabel: DateTimeUtils.getFormattedSelectedDate(
                            _selectedDate ?? DateTime.now(),
                          ),
                          onDateTap: _openCalendar,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(
                                height: AppSizes.kDefaultPadding * 1.4),
                            Row(
                              children: [
                                Expanded(
                                  child: _AcceptedStatTile(
                                    icon: Icons.assignment_turned_in_rounded,
                                    label: 'Routes accepted',
                                    value: '$totalRoutes',
                                    accentColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(
                                    width: AppSizes.kDefaultPadding / 1.2),
                                Expanded(
                                  child: _AcceptedStatTile(
                                    icon: Icons.local_shipping_outlined,
                                    label: 'Active now',
                                    value: '$activeRoutes',
                                    accentColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: AppSizes.kDefaultPadding / 1.2),
                            _AcceptedStatTile(
                              icon: Icons.pending_actions_rounded,
                              label: 'Total stops',
                              value: '$totalStops',
                              accentColor:
                                  Theme.of(context).colorScheme.secondary,
                              isFullWidth: true,
                            ),
                            const SizedBox(height: AppSizes.kDefaultPadding),
                            _AcceptedContextCard(
                              icon: Icons.schedule_rounded,
                              title: 'Next departure',
                              value: nextDeparture,
                              description:
                                  'Be ready before this route starts to keep deliveries on track.',
                            ),
                            const SizedBox(height: AppSizes.kDefaultPadding),
                          ],
                        ),
                      ),
                    ];

                    if (isFailed) {
                      slivers.add(
                        SliverToBoxAdapter(
                          child: _AcceptedErrorState(
                            message:
                                failureMessage ?? 'Unable to load accepted routes.',
                            onRetry: _refresh,
                          ),
                        ),
                      );
                    } else if (routes.isEmpty) {
                      slivers.add(
                        const SliverToBoxAdapter(
                          child: _AcceptedEmptyState(
                            message:
                                'You haven’t accepted any routes for this date. Review available routes or adjust your filters.',
                          ),
                        ),
                      );
                    } else {
                      slivers.add(
                        SliverPadding(
                          padding: EdgeInsets.only(
                            bottom: AppSizes.kDefaultPadding * 2.5 +
                                MediaQuery.of(context).padding.bottom,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final route = routes[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == routes.length - 1
                                        ? 0
                                        : AppSizes.kDefaultPadding * 1.2,
                                  ),
                                  child: RouteCard(route: route),
                                );
                              },
                              childCount: routes.length,
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      color: Theme.of(context).primaryColor,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: slivers,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.primaryColor.withOpacity(0.95),
          theme.primaryColor.withOpacity(0.85),
          theme.scaffoldBackgroundColor,
        ],
      ),
    );
  }

  Widget _buildBackgroundShapes(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
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
    );
  }
}

class _AcceptedHeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final VoidCallback onDateTap;

  const _AcceptedHeroHeader({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding * 1.4,
            vertical: AppSizes.kDefaultPadding * 1.5,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppSizes.cardCornerRadius * 1.6),
            color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 0.9),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.16),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
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
              const SizedBox(width: AppSizes.kDefaultPadding),
              _AcceptedDateSelectorButton(
                label: dateLabel,
                onTap: onDateTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcceptedStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final bool isFullWidth;

  const _AcceptedStatTile({
    required this.icon,
    required this.label,
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
        color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 0.9),
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
                  label,
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

class _AcceptedContextCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String description;

  const _AcceptedContextCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
  });

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
            vertical: AppSizes.kDefaultPadding * 1.1,
          ),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
            color: theme.colorScheme.surface.withOpacity(isDark ? 0.5 : 0.88),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: AppSizes.kDefaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.65,
                        ),
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
}

class _AcceptedDateSelectorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AcceptedDateSelectorButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(
        Icons.calendar_today_rounded,
        size: 18,
        color: theme.primaryColor,
      ),
      label: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor.withOpacity(0.12),
        foregroundColor: theme.primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class _AcceptedEmptyState extends StatelessWidget {
  final String message;

  const _AcceptedEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 42,
              color: theme.primaryColor.withOpacity(0.75),
            ),
            const SizedBox(height: 16),
            Text(
              'No accepted routes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcceptedErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _AcceptedErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
