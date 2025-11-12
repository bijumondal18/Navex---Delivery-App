import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart' hide RouteData;
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navex/presentation/widgets/primary_button.dart';

import '../../../core/resources/app_images.dart';
import '../../../core/themes/app_colors.dart';
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
  bool _isCompleteTripInProgress = false;
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

  bool _isWaypointFailed(Waypoints waypoint) {
    final status = _parseToInt(waypoint.status);
    // Status 2 = Failed
    return status != null && status == 2;
  }

  bool _isWaypointDelivered(Waypoints waypoint) {
    final status = _parseToInt(waypoint.status);
    // Status 1 = Successfully delivered
    return status != null && status == 1;
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.2,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'In Route',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            bottom: 0,
            right: 0,
            child: Column(
              children: [
                // Google Map Widget
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  child: MultiBlocListener(
                    listeners: [
                      BlocListener<RouteBloc, RouteState>(
                        listenWhen: (prev, curr) =>
                            curr is FetchRouteDetailsStateLoaded,
                        listener: (context, state) {
                          if (state is FetchRouteDetailsStateLoaded) {
                            final double lat = double.parse(
                              state.routeData.pickupLat,
                            );
                            final double lng = double.parse(
                              state.routeData.pickupLong,
                            );
                            _showPickupOnMap(lat: lat, lng: lng);
                            if (mounted) {
                              setState(() {
                                _currentRouteData = state.routeData;
                                final bool loaded =
                                    _isFlagTrue(state.routeData.isLoaded);
                                final int? status =
                                    _parseToInt(state.routeData.status);
                                final bool statusCheckedIn =
                                    TripStatusHelper.isAlreadyCheckedIn(
                                  status,
                                );
                                _hasLoadedVehicle = loaded;
                                _hasCheckedIn = statusCheckedIn ||
                                    loaded ||
                                    _hasCheckedIn;
                                _isCheckInInProgress = false;
                                _isLoadVehicleInProgress = false;
                              });
                            }
                          }
                        },
                      ),
                      BlocListener<RouteBloc, RouteState>(
                        listenWhen: (prev, curr) =>
                            curr is CheckInStateLoading ||
                            curr is CheckInStateLoaded ||
                            curr is CheckInStateFailed,
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
                              state.response.message ??
                                  'Checked in successfully',
                              context: context,
                            );
                          } else if (state is CheckInStateFailed) {
                            setState(() => _isCheckInInProgress = false);
                            SnackBarHelper.showError(
                              state.error,
                              context: context,
                            );
                          }
                        },
                      ),
                      BlocListener<RouteBloc, RouteState>(
                        listenWhen: (prev, curr) =>
                            curr is LoadVehicleStateLoading ||
                            curr is LoadVehicleStateLoaded ||
                            curr is LoadVehicleStateFailed,
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
                              state.response.message ??
                                  'Vehicle loaded successfully',
                              context: context,
                            );
                          } else if (state is LoadVehicleStateFailed) {
                            setState(() {
                              _isLoadVehicleInProgress = false;
                            });
                            SnackBarHelper.showError(
                              state.error,
                              context: context,
                            );
                          }
                        },
                      ),
                      BlocListener<RouteBloc, RouteState>(
                        listenWhen: (prev, curr) =>
                            curr is CompleteTripStateLoading ||
                            curr is CompleteTripStateLoaded ||
                            curr is CompleteTripStateFailed,
                        listener: (context, state) {
                          if (!mounted) return;
                          if (state is CompleteTripStateLoading) {
                            setState(() => _isCompleteTripInProgress = true);
                          } else if (state is CompleteTripStateLoaded) {
                            setState(() {
                              _isCompleteTripInProgress = false;
                            });
                            SnackBarHelper.showSuccess(
                              state.response.message ??
                                  'Trip completed successfully',
                              context: context,
                            );
                            // Navigate to home screen after successful trip completion
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (mounted) {
                                context.go(Screens.main);
                              }
                            });
                          } else if (state is CompleteTripStateFailed) {
                            setState(() {
                              _isCompleteTripInProgress = false;
                            });
                            SnackBarHelper.showError(
                              state.error,
                              context: context,
                            );
                          }
                        },
                      ),
                    ],
                    child: Card(
                      elevation: AppSizes.elevationMedium,
                      margin: const EdgeInsets.all(AppSizes.kDefaultPadding),
                      shadowColor: Theme.of(context).shadowColor.withAlpha(100),
                      color: Theme.of(context).cardColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardCornerRadius,
                        ),
                        child: GoogleMap(
                          key: const ValueKey('in_route_map'),
                          initialCameraPosition: const CameraPosition(
                            target: _start,
                            zoom: 14,
                          ),
                          onMapCreated: (c) {
                            if (!_controller.isCompleted) {
                              _controller.complete(c);
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
                ),

                // Distance and Time card Widget
                Card(
                  elevation: AppSizes.elevationMedium,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSizes.kDefaultPadding,
                  ),
                  shadowColor: Theme.of(context).shadowColor.withAlpha(100),
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
                    child: Column(
                      spacing: AppSizes.kDefaultPadding,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              spacing: AppSizes.kDefaultPadding / 3,
                              children: [
                                SvgPicture.asset(
                                  AppImages.pinRed,
                                  width: 20,
                                  height: 20,
                                ),
                                BlocBuilder<RouteBloc, RouteState>(
                                  builder: (context, state) {
                                    final routeData =
                                        state is FetchRouteDetailsStateLoaded
                                            ? state.routeData
                                            : _currentRouteData;
                                    if (routeData != null) {
                                      final distance =
                                          routeData.totalDistance ?? '0';
                                      return Text(
                                        '$distance mi',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      );
                                    }
                                    if (state is FetchRouteDetailsStateFailed) {
                                      return Text(
                                        state.error,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      );
                                    }
                                    return Text(
                                      '0 mi',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    );
                                  },
                                ),
                                Text(
                                  'Distance',
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              spacing: AppSizes.kDefaultPadding / 3,
                              children: [
                                SvgPicture.asset(
                                  AppImages.clockGreen,
                                  width: 20,
                                  height: 20,
                                ),
                                BlocBuilder<RouteBloc, RouteState>(
                                  builder: (context, state) {
                                    final routeData =
                                        state is FetchRouteDetailsStateLoaded
                                            ? state.routeData
                                            : _currentRouteData;
                                    if (routeData != null) {
                                      final totalTime = routeData.totalTime ?? "0";
                                      return Text(
                                        DateTimeUtils
                                            .convertMinutesToHoursMinutes(
                                          totalTime,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      );
                                    }
                                    if (state is FetchRouteDetailsStateFailed) {
                                      return Text(
                                        state.error,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      );
                                    }
                                    return Text(
                                      '0 min',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    );
                                  },
                                ),
                                Text(
                                  'Time',
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .copyWith(
                                        color: Theme.of(context).hintColor,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                BlocBuilder<RouteBloc, RouteState>(
                  builder: (context, state) {
                    final routeData = state is FetchRouteDetailsStateLoaded
                        ? state.routeData
                        : _currentRouteData;
                    if (routeData == null) {
                      return const SizedBox.shrink();
                    }

                    final waypoints = routeData.waypoints ?? [];
                    final shouldReturn =
                        _parseToInt(routeData.driverShouldReturn) == 1;
                    final isVehicleLoaded =
                        _hasLoadedVehicle || _isFlagTrue(routeData.isLoaded);
                    final isCheckInCompleted =
                        _hasCheckedIn || isVehicleLoaded;
                    final int? tripStatus = _parseToInt(routeData.status);
                    final canEnableCheckIn =
                        TripStatusHelper.canEnableCheckIn(tripStatus);
                    final int? currentWaypointId =
                        _parseToInt(routeData.currentWaypoint);
                    final bool isInRouteAndLoaded =
                        tripStatus == 4 && isVehicleLoaded;
                    final bool shouldHideWarehouseButtons =
                        isInRouteAndLoaded;
                    final pickupLat =
                        double.tryParse(routeData.pickupLat) ?? 0.0;
                    final pickupLng =
                        double.tryParse(routeData.pickupLong) ?? 0.0;

                    return Card(
                      elevation: AppSizes.elevationMedium,
                      margin: const EdgeInsets.all(AppSizes.kDefaultPadding),
                      shadowColor: Theme.of(context).shadowColor.withAlpha(100),
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardCornerRadius,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.sizeOf(context).height * 0.3,
                          ),
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              // Warehouse (Pickup) - First Item
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
                                onNavigate: () =>
                                    _navigateToLocation(pickupLat, pickupLng),
                                onCheckIn: _checkIn,
                                onLoadVehicle: _loadVehicle,
                              ),
                              const SizedBox(height: AppSizes.kDefaultPadding * 1.5),
                              // Waypoints
                              ...List.generate(waypoints.length, (index) {
                                final waypoint = waypoints[index];
                                final isLast = index == waypoints.length - 1 && !shouldReturn;
                                
                                // Check if waypoint ID matches current waypoint ID (handle dynamic types)
                                final waypointIdInt = _parseToInt(waypoint.id);
                                final bool isCurrentWaypoint =
                                    currentWaypointId != null &&
                                        waypointIdInt != null &&
                                        currentWaypointId == waypointIdInt;
                                
                                // Check if this waypoint is failed (status=2)
                                final isFailed = _isWaypointFailed(waypoint);
                                
                                // Enable buttons only if waypoint matches current_waypoint ID OR status == 2 (failed)
                                final bool isWaypointEnabled = isCurrentWaypoint || isFailed;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == waypoints.length - 1
                                        ? 0
                                        : AppSizes.kDefaultPadding * 1.5,
                                  ),
                                  child: _buildWaypointItem(
                                    context,
                                    waypoint: waypoint,
                                    index: index + 1,
                                    isLast: isLast,
                                    isEnabled: isWaypointEnabled,
                                  ),
                                );
                              }),
                              // Return to Warehouse (if driverShouldReturn == 1)
                              if (shouldReturn && waypoints.isNotEmpty)
                                const SizedBox(height: AppSizes.kDefaultPadding),
                              if (shouldReturn) ...[
                                // Check if last waypoint is delivered (status=1) or failed (status=2)
                                Builder(
                                  builder: (context) {
                                    final lastWaypoint = waypoints.isNotEmpty 
                                        ? waypoints[waypoints.length - 1] 
                                        : null;
                                    final bool shouldShowWarehouseButtons = lastWaypoint != null &&
                                        (_isWaypointDelivered(lastWaypoint) || 
                                         _isWaypointFailed(lastWaypoint));
                                    
                                    return _buildWarehouseItem(
                                      context,
                                      routeData: routeData,
                                      isFirst: false,
                                      isLast: true,
                                      isVehicleLoaded: true,
                                      showCheckInButton: false,
                                      showActionButtons: shouldShowWarehouseButtons,
                                      canEnableCheckIn: false,
                                      isCheckInCompleted: true,
                                      isCheckInLoading: false,
                                      isLoading: _isCompleteTripInProgress,
                                      onNavigate: () =>
                                          _navigateToLocation(pickupLat, pickupLng),
                                      onCheckIn: () {},
                                      onLoadVehicle: () {},
                                      onCompleteTrip: () => _completeTrip(),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.cardCornerRadius),
        ),
      ),
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kDefaultPadding,
            vertical: AppSizes.kDefaultPadding / 1.5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.kDefaultPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text(
                'Select delivery outcome',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.kDefaultPadding),
              ..._deliveryOptions.map((entry) {
                final (value, icon, label) = entry;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(icon, color: Theme.of(context).primaryColor),
                      title: Text(label, style: textTheme.bodyLarge),
                      onTap: () => Navigator.pop(context, value),
                    ),
                    if (value != _deliveryOptions.last.$1)
                      Divider(
                        height: 0,
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.6),
                      ),
                  ],
                );
              }),
              const SafeArea(
                child: SizedBox(height: AppSizes.kDefaultPadding),
              ),
            ],
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

    final result = await appRouter.push(
      Screens.deliveryOutcome,
      extra: DeliveryOutcomeArgs(
        optionKey: selected.$1,
        title: selected.$3,
        routeId: widget.routeId,
        waypointId: waypoint.id.toString(),
        lat: _currentRouteData?.pickupLat != null
            ? double.tryParse('${_currentRouteData!.pickupLat}')
            : null,
        long: _currentRouteData?.pickupLong != null
            ? double.tryParse('${_currentRouteData!.pickupLong}')
            : null,
      ),
    );

    // Refresh route details after successful delivery to update waypoint status
    if (result == true && mounted) {
      context.read<RouteBloc>().add(FetchRouteDetailsEvent(routeId: widget.routeId));
    }
  }

  Future<void> _failWaypoint(Waypoints waypoint) async {
    if (!mounted) return;
    final result = await appRouter.push(
      Screens.deliveryOutcome,
      extra: DeliveryOutcomeArgs(
        optionKey: 'failed',
        title: 'Failed',
        routeId: widget.routeId,
        waypointId: waypoint.id.toString(),
        lat: _currentRouteData?.pickupLat != null
            ? double.tryParse('${_currentRouteData!.pickupLat}')
            : null,
        long: _currentRouteData?.pickupLong != null
            ? double.tryParse('${_currentRouteData!.pickupLong}')
            : null,
      ),
    );

    // Refresh route details after marking waypoint as failed to update waypoint status
    if (result == true && mounted) {
      context.read<RouteBloc>().add(FetchRouteDetailsEvent(routeId: widget.routeId));
    }
  }

  void _completeTrip() {
    if (_isCompleteTripInProgress) return;
    final now = DateTime.now();
    final completeDate = DateTimeUtils.getFormattedPickedDate(now);
    final completeTime = DateTimeUtils.getFormattedTime(now);
    context.read<RouteBloc>().add(
          CompleteTripEvent(
            routeId: widget.routeId,
            completeDate: completeDate,
            completeTime: completeTime,
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
    VoidCallback? onCompleteTrip,
  }) {
    final Color lineColor = Colors.grey.shade400;
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
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: lineColor),
              ),
              child: const Icon(Icons.warehouse_outlined, size: 16, color: Colors.blueGrey),
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
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_pin,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${routeData.pickupAddress}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (showActionButtons) ...[
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
                      if (isFirst) ...[
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
                      ] else if (onCompleteTrip != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: PrimaryButton(
                            onPressed: isLoading ? null : onCompleteTrip,
                            isLoading: isLoading,
                            label: 'Complete Trip',
                            size: ButtonSize.sm,
                          ),
                        ),
                      ],
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
    final Color lineColor = Colors.grey.shade400;
    final isCompleted = _isWaypointDelivered(waypoint);
    final isFailed = _isWaypointFailed(waypoint);
    final customerName = waypoint.customer?.name ?? 'Customer';
    
    // Determine waypoint color: green for delivered, red for failed, white for pending
    final Color waypointColor = isCompleted 
        ? Colors.green 
        : (isFailed ? Colors.red : Colors.white);

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
                color: waypointColor,
                shape: BoxShape.circle,
                border: Border.all(color: lineColor),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: (isCompleted || isFailed) ? Colors.white : Colors.blueGrey,
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
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${waypoint.address}',
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
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
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
               
                if (waypoint.driverNote != null && '${waypoint.driverNote}'.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.note_alt_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Note: ${waypoint.driverNote}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // Show buttons for enabled waypoints or failed waypoints (to allow retry)
                if ((isEnabled || isFailed) && !isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: (isEnabled || isFailed)
                              ? () => _navigateToLocation(
                                    double.parse('${waypoint.addressLat}'),
                                    double.parse('${waypoint.addressLong}'),
                                  )
                              : null,
                          label: 'Navigate',
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: (isEnabled || isFailed) ? () => _deliverWaypoint(waypoint) : null,
                          label: 'Deliver',
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: (isEnabled || isFailed) ? () => _failWaypoint(waypoint) : null,
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
