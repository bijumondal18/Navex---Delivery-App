import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/date_time_utils.dart';

import '../../data/models/route.dart';

class RouteCard extends StatelessWidget {
  final RouteData? route;

  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(AppSizes.cardCornerRadius * 1.2);
    final String routeTitle = _resolveRouteTitle();
    final String pickupAddress =
        (route?.pickupAddress?.toString().trim().isNotEmpty ?? false)
            ? route!.pickupAddress.toString()
            : 'Pickup location to be confirmed';
    final String startTime = route?.startTime != null
        ? DateTimeUtils.convertToAmPm(route!.startTime.toString())
        : 'Not scheduled';
    final String totalTime = route?.totalTime != null
        ? DateTimeUtils.convertMinutesToHoursMinutes(
            route!.totalTime.toString(),
          )
        : '—';
    final int totalStops = route?.waypoints?.length ?? 0;
    final _RouteStatus status = _RouteStatus.fromValue(
      route?.status,
      theme,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => _handleNavigation(),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding * 1.2,
                vertical: AppSizes.kDefaultPadding * 1.1,
              ),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: theme.colorScheme.surface.withOpacity(
                  theme.brightness == Brightness.dark ? 0.55 : 0.9,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routeTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    pickupAddress,
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withOpacity(0.75),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSizes.kDefaultPadding),
                      _StatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: AppSizes.kDefaultPadding),
                  const Divider(height: 1),
                  const SizedBox(height: AppSizes.kDefaultPadding / 1.2),
                  Wrap(
                    spacing: AppSizes.kDefaultPadding / 1.5,
                    runSpacing: AppSizes.kDefaultPadding / 1.5,
                    children: [
                      _InfoBadge(
                        icon: Icons.schedule_rounded,
                        label: 'Start',
                        value: startTime,
                      ),
                      _InfoBadge(
                        icon: Icons.timelapse_outlined,
                        label: 'Duration',
                        value: totalTime,
                      ),
                      _InfoBadge(
                        icon: Icons.alt_route_outlined,
                        label: 'Stops',
                        value: '$totalStops',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation() {
    if (route == null) return;
    final id = route!.id?.toString() ?? '';
    if (id.isEmpty) return;

    if (route?.status == 3 || route?.status == 4) {
      appRouter.pushNamed(
        Screens.inRoute,
        pathParameters: {'id': id},
      );
    } else {
      appRouter.pushNamed(
        Screens.tripDetails,
        pathParameters: {'id': id},
      );
    }
  }

  String _resolveRouteTitle() {
    if (route == null) return 'Route';
    final title = route?.routeName?.toString().trim();
    if (title != null && title.isNotEmpty) return title;

    final id = route?.id?.toString();
    if (id != null && id.isNotEmpty) {
      return 'Route #$id';
    }
    return 'Route';
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kDefaultPadding * 0.9,
        vertical: AppSizes.kDefaultPadding * 0.6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
        color: theme.colorScheme.surfaceVariant.withOpacity(
          theme.brightness == Brightness.dark ? 0.35 : 0.4,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.primaryColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.6,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _RouteStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: status.color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStatus {
  final String label;
  final Color color;

  const _RouteStatus({
    required this.label,
    required this.color,
  });

  factory _RouteStatus.fromValue(dynamic value, ThemeData theme) {
    final int? statusCode = value is int
        ? value
        : int.tryParse(value?.toString() ?? '');

    switch (statusCode) {
      case 4:
        return _RouteStatus(
          label: 'Completed',
          color: theme.colorScheme.secondary,
        );
      case 3:
        return _RouteStatus(
          label: 'In progress',
          color: theme.colorScheme.tertiary,
        );
      case 2:
        return _RouteStatus(
          label: 'Accepted',
          color: theme.primaryColor,
        );
      case 1:
        return _RouteStatus(
          label: 'Scheduled',
          color: theme.primaryColor,
        );
      default:
        return _RouteStatus(
          label: 'Pending',
          color: theme.colorScheme.outline,
        );
    }
  }
}
