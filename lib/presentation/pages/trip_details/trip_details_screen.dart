import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/presentation/bloc/route_bloc.dart';
import 'package:navex/presentation/widgets/primary_button.dart';

import '../../../core/resources/app_images.dart';
import '../../../core/themes/app_colors.dart';
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
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pickup, zoom: 14),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<RouteBloc>(context).add(
      FetchRouteDetailsEvent(routeId: widget.routeId),
    );
  }

  int? routeStatus;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: screenHeight * 0.2,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Trip Details',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                _buildPickupDropCard(context),
                const SizedBox(height: AppSizes.kDefaultPadding),
                Expanded(child: _buildMapCard(context)),
                const SizedBox(height: AppSizes.kDefaultPadding),
                _buildStatsCard(context),
                _buildAcceptButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDropCard(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.3;

    return Card(
      elevation: AppSizes.elevationMedium,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.kDefaultPadding),
      shadowColor: Theme.of(context).shadowColor.withAlpha(100),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: BlocBuilder<RouteBloc, RouteState>(
            builder: (context, state) {
              if (state is FetchRouteDetailsStateLoading) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              if (state is FetchRouteDetailsStateFailed) {
                return Center(
                  child: Text(
                    state.error,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (state is! FetchRouteDetailsStateLoaded) {
                return const SizedBox.shrink();
              }

              final routeData = state.routeData;
              final pickupAddress =
                  routeData.pickupAddress?.toString().trim().isNotEmpty ?? false
                      ? routeData.pickupAddress.toString()
                      : 'Pickup address unavailable';

              final waypoints = routeData.waypoints ?? [];
              final waypointWidgets = waypoints.isEmpty
                  ? [
                      Text(
                        'No scheduled stops',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    ]
                  : waypoints
                      .map(
                        (waypoint) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '\u2022 ${waypoint.address ?? 'Address unavailable'}',
                            style: Theme.of(context).textTheme.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList();

              final dropLocation = () {
                if (routeData.driverShouldReturn == 1) {
                  return pickupAddress;
                }
                if (waypoints.isNotEmpty) {
                  return waypoints.last.address?.toString() ??
                      'Drop address unavailable';
                }
                return 'Drop address unavailable';
              }();

              return ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSizes.kDefaultPadding * 1.5,
                    ),
                    child: Text(
                      'Pickup',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainer
                                .withAlpha(150),
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.kDefaultPadding / 2),
                  Row(
                    children: [
                      const Icon(Icons.circle_rounded,
                          color: AppColors.greenDark, size: 20),
                      const SizedBox(width: AppSizes.kDefaultPadding / 2),
                      Expanded(
                        child: Text(
                          pickupAddress,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.kDefaultPadding),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSizes.kDefaultPadding * 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: waypointWidgets,
                    ),
                  ),
                  const SizedBox(height: AppSizes.kDefaultPadding),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSizes.kDefaultPadding * 1.5,
                    ),
                    child: Text(
                      'Drop',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainer
                                .withAlpha(150),
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.kDefaultPadding / 2),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AppImages.pinRed,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: AppSizes.kDefaultPadding / 2),
                      Expanded(
                        child: Text(
                          dropLocation,
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMapCard(BuildContext context) {
    return BlocListener<RouteBloc, RouteState>(
      listenWhen: (prev, curr) => curr is FetchRouteDetailsStateLoaded,
      listener: (context, state) {
        if (state is FetchRouteDetailsStateLoaded) {
          final lat = double.tryParse('${state.routeData.pickupLat ?? ''}');
          final lng = double.tryParse('${state.routeData.pickupLong ?? ''}');

          if (lat != null && lng != null) {
            _showPickupOnMap(lat: lat, lng: lng);
          }
        }
      },
      child: Card(
        elevation: AppSizes.elevationMedium,
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.kDefaultPadding),
        shadowColor: Theme.of(context).shadowColor.withAlpha(100),
        color: Theme.of(context).cardColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
          child: GoogleMap(
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
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return BlocBuilder<RouteBloc, RouteState>(
      builder: (context, state) {
        String distanceText = '0 mi';
        String timeText = '0 min';

        if (state is FetchRouteDetailsStateLoaded) {
          final distance = state.routeData.totalDistance;
          distanceText = '${distance ?? 0} mi';

          final totalTime = state.routeData.totalTime ?? "0";
          timeText = DateTimeUtils.convertMinutesToHoursMinutes(totalTime);
        } else if (state is FetchRouteDetailsStateFailed) {
          distanceText = state.error;
          timeText = state.error;
        }

        return Card(
          elevation: AppSizes.elevationMedium,
          margin: const EdgeInsets.symmetric(horizontal: AppSizes.kDefaultPadding),
          shadowColor: Theme.of(context).shadowColor.withAlpha(100),
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatTile(
                  icon: SvgPicture.asset(AppImages.pinRed, width: 20, height: 20),
                  value: distanceText,
                  label: 'Distance',
                ),
                _StatTile(
                  icon:
                      SvgPicture.asset(AppImages.clockGreen, width: 20, height: 20),
                  value: timeText,
                  label: 'Time',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return BlocListener<RouteBloc, RouteState>(
      listener: (context, state) {
        if (state is FetchRouteDetailsStateLoaded) {
          routeStatus = state.routeData.status;
        }
      },
      child: SafeArea(
        top: false,
        child: Visibility(
          visible: routeStatus == 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.kDefaultPadding,
              vertical: AppSizes.kDefaultPadding,
            ),
            child: BlocConsumer<RouteBloc, RouteState>(
              listener: (context, state) {
                if (state is AcceptRouteStateLoaded) {
                  SnackBarHelper.showSuccess(
                    state.acceptedRouteResponse.message ?? 'Route accepted',
                    context: context,
                  );
                  context.read<RouteBloc>().add(
                        FetchUpcomingRoutesEvent(
                          date: DateTimeUtils.getFormattedPickedDate(DateTime.now()),
                        ),
                      );
                  appRouter.go(Screens.main);
                }
                if (state is AcceptRouteStateFailed) {
                  SnackBarHelper.showError(
                    state.error,
                    context: context,
                  );
                }
              },
              builder: (context, state) {
                if (state is AcceptRouteStateLoading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                return PrimaryButton(
                  label: 'Accept',
                  onPressed: () {
                    context
                        .read<RouteBloc>()
                        .add(AcceptRouteEvent(routeId: widget.routeId));
                  },
                  fullWidth: true,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final Widget icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: AppSizes.kDefaultPadding / 3,
      children: [
        icon,
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}
