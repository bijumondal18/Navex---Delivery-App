import 'package:flutter/material.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/date_time_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                    'All Routes',
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
            top: 80,
            left: 0,
            bottom: 0,
            right: 0,
            child: ListView.builder(
              itemCount: 8,
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding,
              ),
              itemBuilder: (context, index) {
                return Container(
                  height: 120,
                  margin: EdgeInsets.only(
                    bottom: AppSizes.kDefaultPadding / 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      AppSizes.cardCornerRadius,
                    ),
                    border: Border.all(
                      width: 1.0,
                      color: Theme.of(context).dividerColor,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withAlpha(10),
                        blurRadius: AppSizes.blurRadius,
                        spreadRadius: AppSizes.spreadRadius,
                      ),
                    ],
                  ),
                  child: Column(children: []),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
