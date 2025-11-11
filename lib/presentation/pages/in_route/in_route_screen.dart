import 'dart:async';
import 'dart:ui';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navex/presentation/widgets/primary_button.dart';
import 'package:navex/presentation/widgets/themed_activity_indicator.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/trip_status_utils.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/screens.dart';
import '../../bloc/route_bloc.dart';
import '../../../data/models/waypoints.dart';
import '../../../data/models/route.dart';
import 'delivery_outcome_screen.dart';

const _deliveryOptions = [
  ('recipient', Icons.person_outline, 'Deliver to recipient'),
  ('third_party', Icons.group_outlined, 'Deliver to third party'),
  ('mailbox', Icons.markunread_mailbox_outlined, 'Left in mailbox'),
  ('safe_place', Icons.home_outlined, 'Left in safe place'),
  ('other', Icons.more_horiz, 'Other'),
];

class InRouteScreen extends StatefulWidget {
  final String routeId;

  const InRouteScreen({super.key, required this.routeId});

  @override
  State<InRouteScreen> createState() => _InRouteScreenState();
}

class _InRouteScreenState extends State<InRouteScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _start = LatLng(28.6139, 77.2090); // New Delhi
  final Set<Marker> _markers = {};

  bool _isLoadVehicleInProgress = false;
  bool _hasLoadedVehicle = false;
  bool _hasCheckedIn = false;
  bool _isCheckInInProgress = false;
  RouteData? _currentRouteData;

  int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool _isFlagTrue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == '1' || normalized == 'true';
    }
    return false;
  }

  bool _isWaypointCompleted(Waypoints waypoint) {
    final status = _parseToInt(waypoint.status);
    return status != null && status != 0;
  }

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

    // Wait a short moment to ensure the map is ready
    final controller = await _controller.future;
    await Future.delayed(const Duration(milliseconds: 300));

    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pickup, zoom: 14),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<RouteBloc>(
      context,
    ).add(FetchRouteDetailsEvent(routeId: widget.routeId));
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    context
        .read<RouteBloc>()
        .add(FetchRouteDetailsEvent(routeId: widget.routeId));
    await Future.delayed(const Duration(milliseconds: 320));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<RouteBloc, RouteState>(
          listenWhen: (previous, current) =>
              current is FetchRouteDetailsStateLoaded,
          listener: (context, state) {
            if (!mounted) return;
            final data = (state as FetchRouteDetailsStateLoaded).routeData;
            final lat = double.tryParse('${data.pickupLat ?? ''}');
            final lng = double.tryParse('${data.pickupLong ?? ''}');
            if (lat != null && lng != null) {
              _showPickupOnMap(lat: lat, lng: lng);
            }
            setState(() {
              _currentRouteData = data;
              final bool loaded = _isFlagTrue(data.isLoaded);
              final int? status = _parseToInt(data.status);
              final bool statusCheckedIn =
                  TripStatusHelper.isAlreadyCheckedIn(status);
              _hasLoadedVehicle = loaded;
              _hasCheckedIn = statusCheckedIn || loaded || _hasCheckedIn;
              _isCheckInInProgress = false;
              _isLoadVehicleInProgress = false;
            });
          },
        ),
        BlocListener<RouteBloc, RouteState>(
          listenWhen: (previous, current) =>
              current is CheckInStateLoading ||
              current is CheckInStateLoaded ||
              current is CheckInStateFailed,
          listener: (context, state) {
            if (!mounted) return;
            if (state is CheckInStateLoading) {
              setState(() => _isCheckInInProgress = true);
            } else if (state is CheckInStateLoaded) {
              setState(() {
                _isCheckInInProgress = false;
                _hasCheckedIn = true;
              });
              SnackBarHelper.showSuccess(
                state.response.message ?? 'Checked in successfully',
                context: context,
              );
            } else if (state is CheckInStateFailed) {
              setState(() => _isCheckInInProgress = false);
              SnackBarHelper.showError(state.error, context: context);
            }
          },
        ),
        BlocListener<RouteBloc, RouteState>(
          listenWhen: (previous, current) =>
              current is LoadVehicleStateLoading ||
              current is LoadVehicleStateLoaded ||
              current is LoadVehicleStateFailed,
          listener: (context, state) {
            if (!mounted) return;
            if (state is LoadVehicleStateLoading) {
              setState(() => _isLoadVehicleInProgress = true);
            } else if (state is LoadVehicleStateLoaded) {
              setState(() {
                _isLoadVehicleInProgress = false;
                _hasLoadedVehicle = true;
                _hasCheckedIn = true;
              });
              SnackBarHelper.showSuccess(
                state.response.message ?? 'Vehicle loaded successfully',
                context: context,
              );
            } else if (state is LoadVehicleStateFailed) {
              setState(() => _isLoadVehicleInProgress = false);
              SnackBarHelper.showError(state.error, context: context);
            }
          },
        ),
      ],
      child: Container(
        decoration: _buildBackgroundGradient(context),
        child: Stack(
          children: [
            _buildBackgroundShapes(context),
            SafeArea(
              child: BlocBuilder<RouteBloc, RouteState>(
                builder: (context, state) {
                  final bool isLoading =
                      state is FetchRouteDetailsStateLoading &&
                          _currentRouteData == null;
                  final bool isFailed =
                      state is FetchRouteDetailsStateFailed &&
                          _currentRouteData == null;
                  final String? failureMessage =
                      state is FetchRouteDetailsStateFailed
                          ? state.error
                          : null;
                  final RouteData? routeData =
                      state is FetchRouteDetailsStateLoaded
                          ? state.routeData
                          : _currentRouteData;

                  if (isLoading) {
                    return Center(child: ThemedActivityIndicator());
                  }

                  if (isFailed) {
                    return _InRouteError(
                      message:
                          failureMessage ?? 'Unable to load route progress.',
                      onRetry: _refresh,
                    );
                  }

                  if (routeData == null) {
                    return const SizedBox.shrink();
                  }

                  final List<Widget> slivers = [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.kDefaultPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: AppSizes.kDefaultPadding * 2.5,
                            ),
                            _RouteOverviewPanel(
                              route: routeData,
                              hasLoadedVehicle:
                                  _hasLoadedVehicle ||
                                      _isFlagTrue(routeData.isLoaded),
                              hasCheckedIn: _hasCheckedIn,
                            ),
                            if (failureMessage != null) ...[
                              const SizedBox(height: AppSizes.kDefaultPadding),
                              _InlineNotice(message: failureMessage),
                            ],
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
                        child: _MapSection(
                          map: GoogleMap(
                            key: const ValueKey('in_route_map'),
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
                            mapType: MapType.normal,
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
                            _RouteMetricsPanel(route: routeData),
                            const SizedBox(
                              height: AppSizes.kDefaultPadding * 1.4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: AppSizes.kDefaultPadding,
                        right: AppSizes.kDefaultPadding,
                        bottom: AppSizes.kDefaultPadding * 2.5 +
                            MediaQuery.of(context).padding.bottom,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _buildTimelinePanel(context, routeData),
                      ),
                    ),
                  ];

                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _refresh,
                        color: theme.primaryColor,
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: slivers,
                        ),
                      ),
                      const Positioned(
                        top: AppSizes.kDefaultPadding,
                        left: AppSizes.kDefaultPadding,
                        child: _FloatingBackButton(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelinePanel(BuildContext context, RouteData routeData) {
    final theme = Theme.of(context);
    final waypoints = routeData.waypoints ?? [];
    final bool shouldReturn =
        _parseToInt(routeData.driverShouldReturn) == 1;
    final bool isVehicleLoaded =
        _hasLoadedVehicle || _isFlagTrue(routeData.isLoaded);
    final bool isCheckInCompleted = _hasCheckedIn || isVehicleLoaded;
    final int? tripStatus = _parseToInt(routeData.status);
    final bool canEnableCheckIn =
        TripStatusHelper.canEnableCheckIn(tripStatus);
    final int? currentWaypointId = _parseToInt(routeData.currentWaypoint);
    final bool isInRouteAndLoaded = tripStatus == 4 && isVehicleLoaded;
    final bool shouldHideWarehouseButtons = isInRouteAndLoaded;

    final double? pickupLat =
        double.tryParse('${routeData.pickupLat ?? ''}');
    final double? pickupLng =
        double.tryParse('${routeData.pickupLong ?? ''}');

    void navigateToPickup() {
      if (pickupLat == null || pickupLng == null) {
        SnackBarHelper.showError(
          'Pickup location unavailable',
          context: context,
        );
        return;
      }
      _navigateToLocation(pickupLat, pickupLng);
    }

    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery workflow',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSizes.kDefaultPadding),
          _buildWarehouseItem(
            context,
            routeData: routeData,
            isFirst: true,
            isLast: waypoints.isEmpty && !shouldReturn,
            isVehicleLoaded: isVehicleLoaded,
            showCheckInButton: true,
            showActionButtons: !shouldHideWarehouseButtons,
            canEnableCheckIn: canEnableCheckIn,
            isCheckInCompleted: isCheckInCompleted,
            isCheckInLoading: _isCheckInInProgress,
            isLoading: _isLoadVehicleInProgress,
            onNavigate: navigateToPickup,
            onCheckIn: _checkIn,
            onLoadVehicle: _loadVehicle,
          ),
          if (waypoints.isNotEmpty)
            const SizedBox(height: AppSizes.kDefaultPadding * 1.2),
          for (var i = 0; i < waypoints.length; i++) ...[
            _buildWaypointItem(
              context,
              waypoint: waypoints[i],
              index: i + 1,
              isLast: i == waypoints.length - 1 && !shouldReturn,
              isEnabled: isInRouteAndLoaded
                  ? (currentWaypointId != null &&
                      _parseToInt(waypoints[i].id) == currentWaypointId)
                  : (i == 0
                      ? isVehicleLoaded
                      : _isWaypointCompleted(waypoints[i - 1])),
            ),
            if (i != waypoints.length - 1)
              const SizedBox(height: AppSizes.kDefaultPadding * 1.2),
          ],
          if (shouldReturn) ...[
            if (waypoints.isNotEmpty)
              const SizedBox(height: AppSizes.kDefaultPadding * 1.2),
            _buildWarehouseItem(
              context,
              routeData: routeData,
              isFirst: false,
              isLast: true,
              isVehicleLoaded: true,
              showCheckInButton: false,
              showActionButtons: false,
              canEnableCheckIn: false,
              isCheckInCompleted: true,
              isCheckInLoading: false,
              isLoading: false,
              onNavigate: navigateToPickup,
              onCheckIn: () {},
              onLoadVehicle: () {},
            ),
          ],
        ],
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

  Future<void> _navigateToLocation(double lat, double lng) async {
    final availableMaps = await _getAvailableMaps(lat, lng);
    
    if (availableMaps.isEmpty) {
      // Fallback to Google Maps web if no map apps are available
      final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    if (availableMaps.length == 1) {
      // If only one map app is available, open it directly
      await _launchMap(availableMaps.first, lat, lng);
      return;
    }

    // Show dialog with multiple map options
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _MapSelectionDialog(
          availableMaps: availableMaps,
          lat: lat,
          lng: lng,
        );
      },
    );
  }

  Future<List<MapApp>> _getAvailableMaps(double lat, double lng) async {
    final allMaps = [
      MapApp(
        name: 'Google Maps',
        icon: Icons.map,
        url: 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
        scheme: 'comgooglemaps://',
      ),
      MapApp(
        name: 'Waze',
        icon: Icons.navigation,
        url: 'https://waze.com/ul?ll=$lat,$lng&navigate=yes',
        scheme: 'waze://',
      ),
      MapApp(
        name: 'Apple Maps',
        icon: Icons.map_outlined,
        url: 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d',
        scheme: 'maps://',
      ),
      MapApp(
        name: 'Bing Maps',
        icon: Icons.explore,
        url: 'https://www.bing.com/maps?rtp=~pos.$lat,$lng',
        scheme: 'bingmaps://',
      ),
      MapApp(
        name: 'Yandex Maps',
        icon: Icons.location_on,
        url: 'https://yandex.com/maps/?pt=$lng,$lat&z=18',
        scheme: 'yandexmaps://',
      ),
    ];

    final availableMaps = <MapApp>[];
    for (final map in allMaps) {
      if (map.scheme != null) {
        final schemeUri = Uri.parse(map.scheme!);
        if (await canLaunchUrl(schemeUri)) {
          availableMaps.add(map);
        }
      } else {
        // Always include maps without scheme (like Google Maps web)
        availableMaps.add(map);
      }
    }

    return availableMaps;
  }

  Future<void> _launchMap(MapApp map, double lat, double lng) async {
    final uri = Uri.parse(map.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _checkIn() async {
    if (_isCheckInInProgress) return;
    setState(() => _isCheckInInProgress = true);
    context.read<RouteBloc>().add(CheckInEvent(routeId: widget.routeId));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permission denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<void> _loadVehicle() async {
    if (_isLoadVehicleInProgress) return;
    setState(() => _isLoadVehicleInProgress = true);
    try {
      final position = await _determinePosition();
      if (!mounted) return;
      context.read<RouteBloc>().add(
            LoadVehicleEvent(
              routeId: widget.routeId,
              currentLat: position.latitude,
              currentLng: position.longitude,
            ),
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadVehicleInProgress = false);
      SnackBarHelper.showError(e.toString(), context: context);
    }
  }

  Future<void> _deliverWaypoint(Waypoints waypoint) async {
    final option = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor:
          Theme.of(context).colorScheme.scrim.withOpacity(0.45),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.kDefaultPadding,
            0,
            AppSizes.kDefaultPadding,
            MediaQuery.of(context).viewInsets.bottom +
                AppSizes.kDefaultPadding,
          ),
          child: _DeliveryOutcomeSheet(
            options: _deliveryOptions,
            onSelect: (value) => Navigator.of(context).pop(value),
          ),
        );
      },
    );

    if (option == null) {
      return;
    }

    final selected = _deliveryOptions.firstWhere(
      (entry) => entry.$1 == option,
      orElse: () => _deliveryOptions.last,
    );

    if (!mounted) return;

    await appRouter.push(
      Screens.deliveryOutcome,
      extra: DeliveryOutcomeArgs(
        optionKey: selected.$1,
        title: selected.$3,
      ),
    );

    // TODO: Implement deliver waypoint API call with selected option
    if (!mounted) return;
    // SnackBarHelper.showSuccess('Delivery completed', context: context);
  }

  Future<void> _failWaypoint(Waypoints waypoint) async {
    if (!mounted) return;
    await appRouter.push(
      Screens.deliveryOutcome,
      extra: DeliveryOutcomeArgs(
        optionKey: 'failed',
        title: 'Failed',
      ),
    );
  }

  Widget _buildWarehouseItem(
    BuildContext context, {
    required RouteData routeData,
    required bool isFirst,
    required bool isLast,
    required bool isVehicleLoaded,
    required bool showCheckInButton,
    bool showActionButtons = true,
    required bool canEnableCheckIn,
    required bool isCheckInCompleted,
    required bool isCheckInLoading,
    required bool isLoading,
    required VoidCallback onNavigate,
    required VoidCallback onCheckIn,
    required VoidCallback onLoadVehicle,
  }) {
    final theme = Theme.of(context);
    final Color lineColor = theme.dividerColor.withOpacity(0.35);
    final isLoaded = isVehicleLoaded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Column
        Column(
          children: [
            if (!isFirst)
              DottedLine(
                direction: Axis.vertical,
                lineLength: 16,
                dashLength: 4,
                dashColor: lineColor,
              ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: lineColor),
              ),
              child: Icon(
                Icons.warehouse_outlined,
                size: 16,
                color: theme.primaryColor,
              ),
            ),
            if (!isLast)
              DottedLine(
                direction: Axis.vertical,
                lineLength: 60,
                dashLength: 4,
                dashColor: lineColor,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.kDefaultPadding / 2),
        // Card content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.kDefaultPadding / 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Warehouse',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: theme.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${routeData.pickupAddress}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (isFirst && showActionButtons) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: onNavigate,
                          label: 'Navigate',
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (showCheckInButton) ...[
                        Expanded(
                          child: PrimaryButton(
                            onPressed: (!canEnableCheckIn ||
                                    isCheckInCompleted ||
                                    isCheckInLoading)
                                ? null
                                : onCheckIn,
                            isLoading: isCheckInLoading,
                            label: 'Check In',
                            size: ButtonSize.sm,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: PrimaryButton(
                          onPressed: (!isCheckInCompleted ||
                                  isCheckInLoading ||
                                  isLoading ||
                                  isLoaded)
                              ? null
                              : onLoadVehicle,
                          isLoading: isLoading,
                          label: 'Load Vehicle',
                          size: ButtonSize.sm,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaypointItem(
    BuildContext context, {
    required Waypoints waypoint,
    required int index,
    required bool isLast,
    required bool isEnabled,
  }) {
    final theme = Theme.of(context);
    final Color lineColor = theme.dividerColor.withOpacity(0.35);
    final isCompleted = _isWaypointCompleted(waypoint);
    final customerName = waypoint.customer?.name ?? 'Customer';
    final double? waypointLat =
        double.tryParse('${waypoint.addressLat ?? ''}');
    final double? waypointLng =
        double.tryParse('${waypoint.addressLong ?? ''}');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Column
        Column(
          children: [
            DottedLine(
              direction: Axis.vertical,
              lineLength: 16,
              dashLength: 4,
              dashColor: lineColor,
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: lineColor),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? theme.colorScheme.onSecondary
                        : theme.primaryColor,
                  ),
                ),
              ),
            ),
            if (!isLast)
              DottedLine(
                direction: Axis.vertical,
                lineLength: 60,
                dashLength: 4,
                dashColor: lineColor,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.kDefaultPadding / 2),
        // Card content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.kDefaultPadding / 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Drop Off',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Icon(
                        Icons.location_pin,
                        color: theme.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${waypoint.address}',
                        maxLines: 2,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (waypoint.customer != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Customer: $customerName',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                    ),
                  ),
                ],
               
                if (waypoint.driverNote != null && '${waypoint.driverNote}'.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        color: theme.hintColor,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Note: ${waypoint.driverNote}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (!isCompleted && isEnabled) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: isEnabled
                              ? () {
                                  if (waypointLat == null ||
                                      waypointLng == null) {
                                    SnackBarHelper.showError(
                                      'Destination unavailable',
                                      context: context,
                                    );
                                    return;
                                  }
                                  _navigateToLocation(waypointLat, waypointLng);
                                }
                              : null,
                          label: 'Navigate',
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: isEnabled ? () => _deliverWaypoint(waypoint) : null,
                          label: 'Deliver',
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: isEnabled ? () => _failWaypoint(waypoint) : null,
                          label: 'Failed',
                          size: ButtonSize.sm,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RouteOverviewPanel extends StatelessWidget {
  final RouteData route;
  final bool hasLoadedVehicle;
  final bool hasCheckedIn;

  const _RouteOverviewPanel({
    required this.route,
    required this.hasLoadedVehicle,
    required this.hasCheckedIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final routeName = (route.routeName?.toString().trim().isNotEmpty ?? false)
        ? route.routeName.toString()
        : 'Route';
    final scheduledDate = route.startDate?.toString();
    final scheduledTime = route.startTime?.toString();
    final formattedDate = scheduledDate != null
        ? DateTimeUtils.formatToDayMonthYear(scheduledDate)
        : 'Date TBC';
    final formattedTime = scheduledTime != null
        ? DateTimeUtils.convertToAmPm(scheduledTime)
        : 'Time TBC';
    final status = _RouteStatus.fromValue(route.status, theme);
    final stops = route.waypoints?.length ?? 0;

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
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
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
                value: '$stops',
              ),
              _InfoBadge(
                icon: Icons.inventory_2_outlined,
                label: 'Vehicle loaded',
                value: hasLoadedVehicle ? 'Yes' : 'Pending',
              ),
              _InfoBadge(
                icon: Icons.verified_user_outlined,
                label: 'Checked in',
                value: hasCheckedIn ? 'Completed' : 'Awaiting',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  final Widget map;

  const _MapSection({required this.map});

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.2),
        child: SizedBox(
          height: 240,
          child: map,
        ),
      ),
    );
  }
}

class _RouteMetricsPanel extends StatelessWidget {
  final RouteData route;

  const _RouteMetricsPanel({required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = route.totalDistance?.toString() ?? '0';
    final duration = route.totalTime?.toString() ?? '0';
    final shouldReturn =
        (route.driverShouldReturn?.toString() ?? '') == '1';

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
                  icon: Icons.route_outlined,
                  label: 'Distance',
                  value: '$distance mi',
                ),
              ),
              const SizedBox(width: AppSizes.kDefaultPadding / 1.2),
              Expanded(
                child: _InfoBadge(
                  icon: Icons.timer_rounded,
                  label: 'Duration',
                  value:
                      DateTimeUtils.convertMinutesToHoursMinutes(duration),
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

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassPanel({
    required this.child,
    this.padding,
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
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding * 1.3,
                vertical: AppSizes.kDefaultPadding * 1.2,
              ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.4),
            color: theme.colorScheme.surface.withOpacity(
              isDark ? 0.55 : 0.92,
            ),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.12),
            ),
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
          label: 'Scheduled',
          color: theme.primaryColor,
        );
      case 1:
        return _RouteStatus(
          label: 'Pending',
          color: theme.primaryColor,
        );
      default:
        return _RouteStatus(
          label: 'Draft',
          color: theme.colorScheme.outline,
        );
    }
  }
}

class _InRouteError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _InRouteError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.kDefaultPadding * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load route progress',
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

class _DeliveryOutcomeSheet extends StatelessWidget {
  final List<(String, IconData, String)> options;
  final ValueChanged<String> onSelect;

  const _DeliveryOutcomeSheet({
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding * 1.1,
            vertical: AppSizes.kDefaultPadding * 1.2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius * 1.6),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface.withOpacity(isDark ? 0.78 : 0.95),
                theme.colorScheme.surfaceVariant.withOpacity(isDark ? 0.65 : 0.88),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: EdgeInsets.only(bottom: AppSizes.kDefaultPadding),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text(
                'Select delivery outcome',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Capture how this stop was completed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.72),
                ),
              ),
              const SizedBox(height: AppSizes.kDefaultPadding * 1.2),
              ...options.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(
                    bottom: entry != options.last
                        ? AppSizes.kDefaultPadding * 0.9
                        : 0,
                  ),
                  child: _DeliveryOutcomeOptionTile(
                    icon: entry.$2,
                    label: entry.$3,
                    onTap: () => onSelect(entry.$1),
                  ),
                ),
              ),
              const SafeArea(
                top: false,
                child: SizedBox(height: AppSizes.kDefaultPadding * 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryOutcomeOptionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DeliveryOutcomeOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_DeliveryOutcomeOptionTile> createState() =>
      _DeliveryOutcomeOptionTileState();
}

class _DeliveryOutcomeOptionTileState extends State<_DeliveryOutcomeOptionTile> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius:
              BorderRadius.circular(AppSizes.cardCornerRadius * 1.3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.kDefaultPadding * 0.9,
              vertical: AppSizes.kDefaultPadding * 0.85,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppSizes.cardCornerRadius * 1.3),
              color: _isPressed
                  ? theme.primaryColor.withOpacity(0.16)
                  : theme.colorScheme.surface.withOpacity(
                      isDark ? 0.55 : 0.88,
                    ),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(
                    _isPressed ? 0.28 : 0.12,
                  ),
                  blurRadius: _isPressed ? 26 : 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: theme.colorScheme.onPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSizes.kDefaultPadding),
                Expanded(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Theme.of(context).colorScheme.surface.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.55 : 0.88,
              ),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class MapApp {
  final String name;
  final IconData icon;
  final String url;
  final String? scheme;

  MapApp({
    required this.name,
    required this.icon,
    required this.url,
    this.scheme,
  });
}

class _MapSelectionDialog extends StatelessWidget {
  final List<MapApp> availableMaps;
  final double lat;
  final double lng;

  const _MapSelectionDialog({
    required this.availableMaps,
    required this.lat,
    required this.lng,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      ),
      backgroundColor: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Select Map App',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSizes.kDefaultPadding),
            // Map list
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: availableMaps.length,
                separatorBuilder: (context, index) => const SizedBox(
                  height: AppSizes.kDefaultPadding / 2,
                ),
                itemBuilder: (context, index) {
                  final map = availableMaps[index];
                  return _MapItem(
                    map: map,
                    lat: lat,
                    lng: lng,
                    onTap: () async {
                      Navigator.of(context).pop();
                      final uri = Uri.parse(map.url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.kDefaultPadding),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.kDefaultPadding / 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapItem extends StatelessWidget {
  final MapApp map;
  final double lat;
  final double lng;
  final VoidCallback onTap;

  const _MapItem({
    required this.map,
    required this.lat,
    required this.lng,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Map icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                map.icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.kDefaultPadding),
            // Map name
            Expanded(
              child: Text(
                map.name,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
