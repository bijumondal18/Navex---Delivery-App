import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:navex/presentation/widgets/primary_button.dart';

import '../../../core/resources/app_images.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../bloc/route_bloc.dart';
import '../../../data/models/waypoints.dart';
import '../../../data/models/route.dart';

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
                  child: BlocListener<RouteBloc, RouteState>(
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
                      }
                    },
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
                                    if (state is FetchRouteDetailsStateLoaded) {
                                      return Text(
                                        '${state.routeData.totalDistance} mi',
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
                                    if (state is FetchRouteDetailsStateLoaded) {
                                      return Text(
                                        DateTimeUtils.convertMinutesToHoursMinutes(
                                          state.routeData.totalTime,
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
                    if (state is FetchRouteDetailsStateLoaded) {
                      final routeData = state.routeData;
                      final waypoints = routeData.waypoints ?? [];
                      final shouldReturn = routeData.driverShouldReturn == 1;
                      
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
                                ),
                                // Waypoints
                                ...waypoints.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final waypoint = entry.value;
                                  final isLast = index == waypoints.length - 1 && !shouldReturn;
                                  final previousCompleted = index == 0 
                                      ? routeData.isLoaded == 1 
                                      : (waypoints[index - 1].status != null && waypoints[index - 1].status != 0);
                                  
                                  return _buildWaypointItem(
                                    context,
                                    waypoint: waypoint,
                                    index: index + 1,
                                    isLast: isLast,
                                    isEnabled: previousCompleted,
                                  );
                                }),
                                // Return to Warehouse (if driverShouldReturn == 1)
                                if (shouldReturn)
                                  _buildWarehouseItem(
                                    context,
                                    routeData: routeData,
                                    isFirst: false,
                                    isLast: true,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
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

  Future<void> _loadVehicle() async {
    // TODO: Implement load vehicle API call
    // After success, update routeData.isLoaded = 1
    SnackBarHelper.showSuccess('Vehicle loaded successfully', context: context);
  }

  Future<void> _deliverWaypoint(Waypoints waypoint) async {
    // TODO: Implement deliver waypoint API call
    // After success, update waypoint.status
    SnackBarHelper.showSuccess('Delivery completed', context: context);
  }

  Future<void> _failWaypoint(Waypoints waypoint) async {
    // TODO: Implement fail waypoint API call
    // After success, update waypoint.status
    SnackBarHelper.showError('Delivery marked as failed', context: context);
  }

  Widget _buildWarehouseItem(
    BuildContext context, {
    required RouteData routeData,
    required bool isFirst,
    required bool isLast,
  }) {
    final Color lineColor = Colors.grey.shade400;
    final isLoaded = routeData.isLoaded == 1;

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
                if (isFirst) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: () => _navigateToLocation(
                            double.parse('${routeData.pickupLat}'),
                            double.parse('${routeData.pickupLong}'),
                          ),
                          label: 'Navigate',
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: isLoaded ? null : _loadVehicle,
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
    final Color lineColor = Colors.grey.shade400;
    final isCompleted = waypoint.status != null && waypoint.status != 0;
    final customerName = waypoint.customer?.name ?? 'Customer';

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
                color: isCompleted ? Colors.green : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: lineColor),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.white : Colors.blueGrey,
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
                Text(
                  'Drop Off',
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
                        '${waypoint.address}',
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
                if (waypoint.packageCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Packages: ${waypoint.packageCount}',
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
                if (!isCompleted) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: isEnabled
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
