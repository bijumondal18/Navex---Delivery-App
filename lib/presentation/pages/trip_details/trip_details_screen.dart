import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
            left: 0,
            bottom: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.vertical(
                top: Radius.circular(AppSizes.cardCornerRadius),
              ),
              child: Material(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
                  child: SafeArea(
                    child: Column(
                      spacing: AppSizes.kDefaultPadding,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              flex: 4,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2.0,
                                      right: 8.0,
                                    ),
                                    child: SvgPicture.asset(
                                      AppImages.pinRed,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: AppSizes.kDefaultPadding / 3,
                                    children: [
                                      Text(
                                        'Distance'.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                      ),
                                      Text(
                                        '0.2 km',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: const VerticalDottedDivider(
                                height: 64,
                                dotSize: 3,
                                gap: 8,
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2.0,
                                      right: 8.0,
                                    ),
                                    child: SvgPicture.asset(
                                      AppImages.clockGreen,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: AppSizes.kDefaultPadding / 3,
                                    children: [
                                      Text(
                                        'Time'.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Theme.of(
                                                context,
                                              ).hintColor,
                                            ),
                                      ),
                                      Text(
                                        '2 min',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        PrimaryButton(
                          label: 'Accept',
                          onPressed: () {},
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
