import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:navex/presentation/widgets/primary_button.dart';

import '../../../core/resources/app_images.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../bloc/route_bloc.dart';

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
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.3,
                  ),
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
                        // _showPickupOnMap(lat: lat, lng: lng);
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
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.3,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          _buildTimelineItem(
                            context,
                            icon: Icons.warehouse_outlined,
                            title: 'Warehouse',
                            address: '105 William St, Chicago, US',
                            isFirst: true,
                          ),
                          _buildTimelineItem(
                            context,
                            number: 1,
                            title: 'Drop Off',
                            address: '105 William St, Chicago, US',
                            time: '08.30 pm',
                            note: '',
                            showButtons: true,
                          ),
                          _buildTimelineItem(
                            context,
                            number: 2,
                            title: 'Drop Off',
                            address: '105 William St, Chicago, US',
                            time: '08.30 pm',
                            note: '',
                            showButtons: true,
                          ),
                          _buildTimelineItem(
                            context,
                            icon: Icons.warehouse_outlined,
                            title: 'Warehouse',
                            address: '105 William St, Chicago, US',
                            isLast: true,
                          ),
                        ],
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

  Widget _buildTimelineItem(
    BuildContext context, {
    int? number,
    IconData? icon,
    required String title,
    required String address,
    String? time,
    String? note,
    bool showButtons = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final Color lineColor = Colors.grey.shade400;

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
              child: icon != null
                  ? Icon(icon, size: 16, color: Colors.blueGrey)
                  : Center(
                      child: Text(
                        '$number',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
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
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600),
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
                        address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (time != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
                if (note != null) ...[
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
                          'Note: $note',
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
                if (showButtons) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          onPressed: () {},
                          label: 'Navigate',
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: () {},
                          label: 'Deliver',
                          size: ButtonSize.sm,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          onPressed: () {},
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
