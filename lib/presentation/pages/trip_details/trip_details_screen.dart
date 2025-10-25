import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/presentation/bloc/route_bloc.dart';
import 'package:navex/presentation/widgets/primary_button.dart';

import '../../../core/resources/app_images.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../widgets/vertical_dotted_divider.dart';

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
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: pickup, zoom: 14)),
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<RouteBloc>(
      context,
    ).add(FetchRouteDetailsEvent(routeId: widget.routeId));
  }

  int? routeStatus;

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
                    'Trip Details',
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
                Card(
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
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.3,
                      child: ListView(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSizes.kDefaultPadding * 1.5,
                                ),
                                child: Text(
                                  'Pickup'.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainer
                                            .withAlpha(150),
                                      ),
                                ),
                              ),
                              Row(
                                spacing: AppSizes.kDefaultPadding / 2,
                                children: [
                                  Icon(
                                    Icons.circle_rounded,
                                    color: AppColors.greenDark,
                                    size: 20,
                                  ),
                                  Expanded(
                                    child: BlocBuilder<RouteBloc, RouteState>(
                                      builder: (context, state) {
                                        if (state
                                            is FetchRouteDetailsStateLoaded) {
                                          return Text(
                                            '${state.routeData.pickupAddress}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        return Text(
                                          'Loading...',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSizes.kDefaultPadding),
                          BlocBuilder<RouteBloc, RouteState>(
                            builder: (context, state) {
                              if (state is FetchRouteDetailsStateLoaded) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSizes.kDefaultPadding * 2,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: state.routeData.waypoints!
                                        .map(
                                          (waypoint) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                            ),
                                            child: Text(
                                              "\u2022 ${waypoint.address}",
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelLarge,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: AppSizes.kDefaultPadding),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSizes.kDefaultPadding * 1.5,
                                ),
                                child: Text(
                                  'Drop'.toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainer
                                            .withAlpha(150),
                                      ),
                                ),
                              ),
                              Row(
                                spacing: AppSizes.kDefaultPadding / 2,
                                children: [
                                  SvgPicture.asset(
                                    AppImages.pinRed,
                                    width: 20,
                                    height: 20,
                                  ),
                                  Expanded(
                                    child: BlocBuilder<RouteBloc, RouteState>(
                                      builder: (context, state) {
                                        if (state
                                            is FetchRouteDetailsStateLoaded) {
                                          var lastWaypoint = "";
                                          if (state.routeData.waypoints !=
                                                  null &&
                                              state
                                                  .routeData
                                                  .waypoints!
                                                  .isNotEmpty) {
                                            lastWaypoint = state
                                                .routeData
                                                .waypoints
                                                ?.last
                                                .address;
                                          }

                                          String drop = "";
                                          if (state
                                                  .routeData
                                                  .driverShouldReturn ==
                                              1) {
                                            drop =
                                                "${state.routeData.pickupAddress}";
                                          } else {
                                            drop = lastWaypoint;
                                          }
                                          return Text(
                                            drop,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }
                                        return Text(
                                          'Loading...',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        );
                                      },
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
                ),

                Expanded(
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardCornerRadius,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardCornerRadius,
                        ),
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: _start,
                            zoom: 12,
                          ),
                          onMapCreated: (c) => _controller.complete(c),
                          markers: _markers,
                          myLocationEnabled: false,
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
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
                                        '${state.routeData.totalDistanceKm} km',
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
                                      '0 km',
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
                BlocListener<RouteBloc, RouteState>(
                  listener: (context, state) {
                    if (state is FetchRouteDetailsStateLoaded) {
                      routeStatus = state.routeData.status;
                    }
                  },
                  child: SafeArea(
                    child: Visibility(
                      visible: routeStatus == 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.kDefaultPadding,
                        ),
                        child: BlocConsumer<RouteBloc, RouteState>(
                          listener: (context, state) {
                            if (state is AcceptRouteStateLoaded) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${state.acceptedRouteResponse.message}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(color: AppColors.white),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                ),
                              );
                              // appRouter.go(Screens.home);
                            }
                            if (state is AcceptRouteStateFailed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.error,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(color: AppColors.white),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.errorLight
                                      .withAlpha(150),
                                ),
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
                                context.read<RouteBloc>().add(
                                  AcceptRouteEvent(routeId: widget.routeId),
                                );
                              },
                              fullWidth: true,
                            );
                          },
                        ),
                      ),
                    ),
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
