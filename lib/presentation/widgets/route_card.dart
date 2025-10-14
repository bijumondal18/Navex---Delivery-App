import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/date_time_utils.dart';
import 'package:navex/presentation/bloc/route_bloc.dart';

import '../../data/models/route.dart';

class RouteCard extends StatelessWidget {
  final RouteData? route;
  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        appRouter.pushNamed(Screens.tripDetails, pathParameters: {'id': route!.id.toString()});
      },
      child: Card(
        elevation: AppSizes.elevationSmall,
        color: Theme.of(context).cardColor,
        shadowColor: Theme.of(context).colorScheme.onSurface.withAlpha(200),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.kDefaultPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.kDefaultPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column with pin, dotted line, and circle
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: SvgPicture.asset(
                            AppImages.pinRed,
                            width: 20,
                            height: 20,
                          ),
                        ),
                        SizedBox(
                          height: 24, // space for dotted line
                          child: DottedLine(
                            direction: Axis.vertical,
                            lineLength: double.infinity,
                            dashLength: 4,
                            dashGapLength: 4,
                            dashColor: Theme.of(context).hintColor,
                          ),
                        ),
                        SvgPicture.asset(
                          AppImages.circleGreen,
                          width: 18,
                          height: 18,
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.kDefaultPadding / 2),
                    // Labels beside icons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${route?.pickupAddress}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 22),
                          Text(
                            DateTimeUtils.convertToAmPm(route!.startTime.toString()),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Theme.of(context).dividerColor),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.kDefaultPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.timer, width: 20, height: 20),
                    const SizedBox(width: AppSizes.kDefaultPadding / 2),
                    Text(
                      DateTimeUtils.convertMinutesToHoursMinutes(route!.totalTime.toString()),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Text(
                    //   "Completed",
                    //   style: Theme.of(context).textTheme.labelLarge,
                    // ),
                    // const SizedBox(width: 4),
                    // Icon(
                    //   Icons.arrow_forward_ios_rounded,
                    //   size: 16,
                    //   color: Theme.of(context).hintColor,
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
