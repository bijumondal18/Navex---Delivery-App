import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
  @override
  void initState() {
    BlocProvider.of<RouteBloc>(
      context,
    ).add(FetchRouteDetailsEvent(routeId: widget.routeId));
    super.initState();
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
                    'Trip Details',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: AppColors.white),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.kDefaultPadding,
                      vertical: AppSizes.kDefaultPadding / 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackgroundDark.withAlpha(100),
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardCornerRadius * 5,
                      ),
                    ),
                    child: Text(
                      DateTimeUtils.getFormattedCurrentDate(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 16,
            bottom: 48,
            right: 16,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.all(
                    Radius.circular(AppSizes.cardCornerRadius),
                  ),
                  child: Material(
                    color: Theme.of(context).cardColor,
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
                                      if (state
                                          is FetchRouteDetailsStateLoaded) {
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
                                      if (state
                                          is FetchRouteDetailsStateFailed) {
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
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
                                      if (state
                                          is FetchRouteDetailsStateLoaded) {
                                        return Text(
                                          DateTimeUtils.convertMinutesToHoursMinutes(state.routeData.totalTime),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        );
                                      }
                                      if(state is FetchRouteDetailsStateFailed){
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
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
                ),
                const SizedBox(height: AppSizes.kDefaultPadding),
                PrimaryButton(
                  label: 'Accept',
                  onPressed: () {},
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
