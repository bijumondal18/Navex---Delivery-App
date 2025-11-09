import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/date_time_utils.dart';
import 'package:navex/presentation/widgets/route_card.dart';

import '../../bloc/route_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RouteBloc>().add(
          FetchUpcomingRoutesEvent(
            date: DateTimeUtils.getFormattedPickedDate(DateTime.now()),
          ),
        );
  }

  @override
  void dispose() {
    super.dispose();
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
            top: 70,
            left: 0,
            bottom: 0,
            right: 0,
            child: BlocBuilder<RouteBloc, RouteState>(
              builder: (context, state) {
                if (state is FetchUpcomingRoutesStateLoading) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (state is FetchUpcomingRoutesStateLoaded) {
                  final route = state.routeResponse.route ?? [];
                  return route.isNotEmpty
                      ? ListView.separated(
                    itemCount: route.length,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(
                      left: AppSizes.kDefaultPadding,
                      right: AppSizes.kDefaultPadding,
                      top: AppSizes.kDefaultPadding,
                      bottom: AppSizes.kDefaultPadding * 4,
                    ),
                    itemBuilder: (context, index) {
                      return RouteCard(route: route[index]);
                    },
                    separatorBuilder:
                        (BuildContext context, int index) =>
                    const SizedBox(
                      height: AppSizes.kDefaultPadding / 1.5,
                    ),
                  )
                      : Center(
                    child: Text(
                      'No Available Routes',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                return SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
