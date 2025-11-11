import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/data/models/route.dart';
import 'package:navex/presentation/bloc/route_bloc.dart';
import 'package:navex/presentation/widgets/primary_button.dart';
import 'package:navex/presentation/widgets/themed_activity_indicator.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/snackbar_helper.dart';

class TripDetailsScreen extends StatefulWidget {
  final String routeId;

  const TripDetailsScreen({super.key, required this.routeId});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _start = LatLng(28.6139, 77.2090); // New Delhi
  final Set<Marker> _markers = {};
  static const double _appBarHeight = 72.0;

  Future<void> _showPickupOnMap({
    required double lat,
    required double lng,
  }) async {
    final pickup = LatLng(lat, lng);

    setState(() {
      _markers
        ..removeWhere((m) => m.markerId.value == 'pickup')
        ..add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: pickup,
            infoWindow: const InfoWindow(title: 'Pickup Address'),
          ),
        );
    });

    final controller = await _controller.future;
    await Future.delayed(const Duration(milliseconds: 300));

    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: pickup, zoom: 14)),
    );
  }

  RouteData? _cachedRoute;
  int? _routeStatus;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<RouteBloc>(
      context,
    ).add(FetchRouteDetailsEvent(routeId: widget.routeId));
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    BlocProvider.of<RouteBloc>(
      context,
    ).add(FetchRouteDetailsEvent(routeId: widget.routeId));
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RouteBloc, RouteState>(
          listenWhen: (previous, current) =>
              current is FetchRouteDetailsStateLoaded,
          listener: (context, state) {
            final loaded = (state as FetchRouteDetailsStateLoaded).routeData;
            _cachedRoute = loaded;
            _routeStatus = _parseStatus(loaded.status);

            final lat = double.tryParse('${loaded.pickupLat ?? ''}');
            final lng = double.tryParse('${loaded.pickupLong ?? ''}');
            if (lat != null && lng != null) {
              _showPickupOnMap(lat: lat, lng: lng);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(_appBarHeight),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.kDefaultPadding,
                AppSizes.kDefaultPadding * 0.8,
                AppSizes.kDefaultPadding,
                AppSizes.kDefaultPadding * 0.4,
              ),
              child: _GlassAppBar(
                title: 'Route details',
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: _buildBackgroundGradient(context),
          child: Stack(
            children: [
              _buildBackgroundShapes(context),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        _appBarHeight +
                        AppSizes.kDefaultPadding * 0.4,
                  ),
                  child: _buildScrollableContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        final bool isLoading =
            state is FetchRouteDetailsStateLoading && _cachedRoute == null;
        final bool isFailed =
            state is FetchRouteDetailsStateFailed && _cachedRoute == null;
        final String? failureMessage =
            state is FetchRouteDetailsStateFailed ? state.error : null;
        final RouteData? routeData = state is FetchRouteDetailsStateLoaded
            ? state.routeData
            : _cachedRoute;

        if (isLoading) {
          return const Center(child: ThemedActivityIndicator());
        }

        if (isFailed) {
          return _TripDetailsError(
            message: failureMessage ?? 'Unable to load trip details.',
            onRetry: _refresh,
          );
        }

        if (routeData == null) {
          return const SizedBox.shrink();
        }

        final slivers = <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TripSummaryPanel(route: routeData),
                  if (failureMessage != null) ...[
                    const SizedBox(height: AppSizes.kDefaultPadding),
                    _InlineNotice(message: failureMessage),
                  ],
                  const SizedBox(
                    height: AppSizes.kDefaultPadding * 1.4,
                  ),
                  _PickupStopsPanel(route: routeData),
                  const SizedBox(
                    height: AppSizes.kDefaultPadding * 1.4,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding,
              ),
              child: _MapPanel(
                map: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: _start,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                  markers: _markers,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: AppSizes.kDefaultPadding * 1.4,
                  ),
                  _TripMetricsPanel(route: routeData),
                  if (_routeStatus == 2) ...[
                    const SizedBox(
                      height: AppSizes.kDefaultPadding * 1.4,
                    ),
                    _AcceptAction(
                      routeId: widget.routeId,
                      onRefresh: _refresh,
                    ),
                  ],
                  SizedBox(
                    height: AppSizes.kDefaultPadding * 2.5 +
                        MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
          ),
        ];

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

  int? _parseStatus(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class _TripSummaryPanel extends StatelessWidget {
  final RouteData? route;

  const _TripSummaryPanel({this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeName = (route?.routeName?.toString().trim().isNotEmpty ?? false)
        ? route!.routeName.toString()
        : 'Route';
    final startDate = route?.startDate?.toString();
    final startTime = route?.startTime?.toString();
    final formattedDate = startDate != null
        ? DateTimeUtils.formatToDayMonthYear(startDate)
        : 'Date TBC';
    final formattedTime = startTime != null
        ? DateTimeUtils.convertToAmPm(startTime)
        : 'Time TBC';

    final status = _RouteStatus.fromValue(route?.status, theme);
    final totalStops = route?.waypoints?.length ?? 0;
    final distance = route?.totalDistance?.toString() ?? '0';
    final duration = route?.totalTime?.toString() ?? '0';

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routeName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scheduled for $formattedDate at $formattedTime',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: AppSizes.kDefaultPadding * 1.1),
          Wrap(
            spacing: AppSizes.kDefaultPadding / 1.4,
            runSpacing: AppSizes.kDefaultPadding / 1.4,
            children: [
              _InfoBadge(
                icon: Icons.alt_route_outlined,
                label: 'Stops',
                value: '$totalStops',
              ),
              _InfoBadge(
                icon: Icons.route_outlined,
                label: 'Distance',
                value: '$distance mi',
              ),
              _InfoBadge(
                icon: Icons.schedule_rounded,
                label: 'Duration',
                value: DateTimeUtils.convertMinutesToHoursMinutes(duration),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickupStopsPanel extends StatelessWidget {
  final RouteData? route;

  const _PickupStopsPanel({this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pickupAddress =
        (route?.pickupAddress?.toString().trim().isNotEmpty ?? false)
        ? route!.pickupAddress.toString()
        : 'Pickup address unavailable';
    final waypoints = route?.waypoints ?? [];
    final dropLocation = () {
      if (route == null) return 'Drop address unavailable';
      if ((route!.driverShouldReturn == 1) ||
          (route!.driverShouldReturn?.toString() == '1')) {
        return pickupAddress;
      }
      if (waypoints.isNotEmpty) {
        return waypoints.last.address?.toString() ?? 'Drop address unavailable';
      }
      return 'Drop address unavailable';
    }();

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          _StopTile(
            title: 'Pickup',
            address: pickupAddress,
            leading: Icons.my_location_rounded,
            accentColor: theme.primaryColor,
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          if (waypoints.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding,
                vertical: AppSizes.kDefaultPadding * 0.8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
                color: theme.primaryColor.withOpacity(0.08),
              ),
              child: Text(
                'No scheduled stops',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < waypoints.length; i++) ...[
                  _WaypointRow(
                    index: i + 1,
                    label: waypoints[i].address ?? 'Address unavailable',
                    delivered: (waypoints[i].status?.toString() ?? '') != '0',
                  ),
                  if (i != waypoints.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.kDefaultPadding * 0.5,
                      ),
                      child: Divider(
                        color: theme.dividerColor.withOpacity(0.4),
                      ),
                    ),
                ],
              ],
            ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          _StopTile(
            title: 'Drop',
            address: dropLocation,
            leading: Icons.flag_outlined,
            accentColor: theme.colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  final GoogleMap map;

  const _MapPanel({required this.map});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.2),
        child: SizedBox(height: 240, child: map),
      ),
    );
  }
}

class _TripMetricsPanel extends StatelessWidget {
  final RouteData? route;

  const _TripMetricsPanel({this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = route?.totalDistance?.toString() ?? '0';
    final duration = route?.totalTime?.toString() ?? '0';
    final shouldReturn = (route?.driverShouldReturn?.toString() ?? '') == '1';

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip metrics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          Row(
            children: [
              Expanded(
                child: _InfoBadge(
                  icon: Icons.route_rounded,
                  label: 'Distance',
                  value: '$distance mi',
                ),
              ),
              const SizedBox(width: AppSizes.kDefaultPadding / 1.2),
              Expanded(
                child: _InfoBadge(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: DateTimeUtils.convertMinutesToHoursMinutes(duration),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          _InfoBadge(
            icon: Icons.u_turn_left_outlined,
            label: 'Return to pickup',
            value: shouldReturn ? 'Yes' : 'No',
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _AcceptAction extends StatelessWidget {
  final String routeId;
  final Future<void> Function() onRefresh;

  const _AcceptAction({required this.routeId, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: BlocConsumer<RouteBloc, RouteState>(
        listener: (context, state) {
          if (state is AcceptRouteStateLoaded) {
            SnackBarHelper.showSuccess(
              state.acceptedRouteResponse.message ?? 'Route accepted',
              context: context,
            );
            onRefresh();
            appRouter.go(Screens.main);
          }
          if (state is AcceptRouteStateFailed) {
            SnackBarHelper.showError(state.error, context: context);
          }
        },
        builder: (context, state) {
          if (state is AcceptRouteStateLoading) {
            return const Center(child: ThemedActivityIndicator());
          }
          return PrimaryButton(
            label: 'Accept route',
            fullWidth: true,
            onPressed: () {
              context.read<RouteBloc>().add(AcceptRouteEvent(routeId: routeId));
            },
          );
        },
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassPanel({required this.child, this.padding});

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
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding * 1.3,
                vertical: AppSizes.kDefaultPadding * 1.2,
              ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius * 1.4,
            ),
            color: theme.colorScheme.surface.withOpacity(isDark ? 0.55 : 0.92),
            border: Border.all(color: theme.primaryColor.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.12),
                blurRadius: 32,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFullWidth;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.kDefaultPadding * 0.9,
        vertical: AppSizes.kDefaultPadding * 0.7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
        color: theme.colorScheme.surfaceVariant.withOpacity(
          theme.brightness == Brightness.dark ? 0.35 : 0.45,
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

  const _RouteStatus({required this.label, required this.color});

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
        return _RouteStatus(label: 'Scheduled', color: theme.primaryColor);
      case 1:
        return _RouteStatus(label: 'Pending', color: theme.primaryColor);
      default:
        return _RouteStatus(label: 'Draft', color: theme.colorScheme.outline);
    }
  }
}

class _StopTile extends StatelessWidget {
  final String title;
  final String address;
  final IconData leading;
  final Color accentColor;

  const _StopTile({
    required this.title,
    required this.address,
    required this.leading,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(leading, color: accentColor),
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
                address,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaypointRow extends StatelessWidget {
  final int index;
  final String label;
  final bool delivered;

  const _WaypointRow({
    required this.index,
    required this.label,
    required this.delivered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: delivered
                ? theme.colorScheme.secondary.withOpacity(0.2)
                : theme.primaryColor.withOpacity(0.1),
          ),
          child: Icon(
            delivered ? Icons.check_rounded : Icons.location_on_outlined,
            size: 16,
            color: delivered ? theme.colorScheme.secondary : theme.primaryColor,
          ),
        ),
        const SizedBox(width: AppSizes.kDefaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stop #$index',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.3,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TripDetailsError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _TripDetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.kDefaultPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Unable to load trip details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
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
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  final String message;

  const _InlineNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _GlassPanel(
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _GlassAppBar({
    required this.title,
    required this.onBack,
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
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding * 0.9,
            vertical: AppSizes.kDefaultPadding * 0.75,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppSizes.cardCornerRadius * 1.4,
            ),
            color: theme.colorScheme.surface.withOpacity(
              isDark ? 0.55 : 0.9,
            ),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.14),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: theme.primaryColor,
                  size: 20,
                ),
                onPressed: onBack,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
