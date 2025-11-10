import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/data/models/route.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_picker_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/repositories/route_repository.dart';
import '../../bloc/route_bloc.dart';
import '../../widgets/route_card.dart';
import '../../widgets/themed_activity_indicator.dart';

class AvailableRoutesScreen extends StatefulWidget {
  const AvailableRoutesScreen({super.key});

  @override
  State<AvailableRoutesScreen> createState() => _AvailableRoutesScreenState();
}

class _AvailableRoutesScreenState extends State<AvailableRoutesScreen> {
  DateTime? _selectedDate;
  late final RouteBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RouteBloc(RouteRepository())
      ..add(
        FetchUpcomingRoutesEvent(
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
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
      _bloc.add(
        FetchUpcomingRoutesEvent(
          date: DateTimeUtils.getFormattedPickedDate(pickedDate),
        ),
      );
    }
  }

  Future<void> _refresh() async {
    final targetDate = _selectedDate ?? DateTime.now();
    _bloc.add(
      FetchUpcomingRoutesEvent(
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
                        state is FetchUpcomingRoutesStateLoading;
                    final bool isFailed =
                        state is FetchUpcomingRoutesStateFailed;
                    String? failureMessage;
                    if (state is FetchUpcomingRoutesStateFailed) {
                      failureMessage = state.error;
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
                        _HeroHeader(
                          title: 'Available routes',
                          subtitle:
                              'Select a route to review details and accept the delivery.',
                          dateLabel: DateTimeUtils.getFormattedSelectedDate(
                            _selectedDate ?? DateTime.now(),
                          ),
                          onDateTap: _openCalendar,
                        ),
                        const SizedBox(height: AppSizes.kDefaultPadding * 1.4),
                        Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                icon: Icons.route_outlined,
                                label: 'Total routes',
                                value: '$totalRoutes',
                                accentColor: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(
                                width: AppSizes.kDefaultPadding / 1.2),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.alt_route_rounded,
                                label: 'Stops today',
                                value: '$totalStops',
                                accentColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.kDefaultPadding / 1.2),
                        _StatTile(
                          icon: Icons.schedule_rounded,
                          label: 'Next departure',
                          value: nextDeparture,
                          accentColor:
                              Theme.of(context).colorScheme.secondary,
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
                                    ? _ErrorState(
                                        message: failureMessage ??
                                            'Something went wrong',
                                        onRetry: _refresh,
                                      )
                                    : routes.isEmpty
                                        ? const _EmptyState(
                                            message:
                                                'No routes are currently available. Check back soon or adjust your date filter.',
                                          )
                                        : RefreshIndicator(
                                            onRefresh: _refresh,
                                            color:
                                                Theme.of(context).primaryColor,
                                            child: ListView.separated(
                                              physics:
                                                  const BouncingScrollPhysics(
                                                parent:
                                                    AlwaysScrollableScrollPhysics(),
                                              ),
                                              padding: const EdgeInsets.only(
                                                left: 2,
                                                right: 2,
                                                bottom: AppSizes
                                                        .kDefaultPadding *
                                                    5,
                                              ),
                                              itemCount: routes.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(
                                                height: AppSizes
                                                        .kDefaultPadding /
                                                    1.5,
                                              ),
                                              itemBuilder: (_, index) =>
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

class _HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateLabel;
  final VoidCallback onDateTap;

  const _HeroHeader({
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
            borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.6),
            color: theme.colorScheme.surface.withOpacity(
              isDark ? 0.55 : 0.9,
            ),
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
              _DateSelectorButton(
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

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final bool isFullWidth;

  const _StatTile({
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

class _DateSelectorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateSelectorButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.calendar_today_rounded, size: 18, color: theme.primaryColor),
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

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

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
              Icons.auto_awesome,
              size: 42,
              color: theme.primaryColor.withOpacity(0.75),
            ),
            const SizedBox(height: 16),
            Text(
              'You’re all caught up',
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

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
