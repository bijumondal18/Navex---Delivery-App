import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_picker_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/repositories/route_repository.dart';
import '../../bloc/route_bloc.dart';
import '../../widgets/route_card.dart';
import '../../widgets/themed_activity_indicator.dart';

class RouteHistoryScreen extends StatefulWidget {
  const RouteHistoryScreen({super.key});

  @override
  State<RouteHistoryScreen> createState() => _RouteHistoryScreenState();
}

class _RouteHistoryScreenState extends State<RouteHistoryScreen> {
  late final RouteBloc _bloc;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _bloc = RouteBloc(RouteRepository())
      ..add(
        FetchRouteHistoryEvent(
          date: DateTimeUtils.getFormattedPickedDate(_selectedDate),
        ),
      );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _openCalendar() async {
    final DateTime? pickedDate = await showAppDatePicker(
      context: context,
      barrierDismissible: false,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
      _bloc.add(
        FetchRouteHistoryEvent(
          date: DateTimeUtils.getFormattedPickedDate(pickedDate),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: SizedBox(
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
                      'Route History',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(color: AppColors.white),
                    ),
                    GestureDetector(
                      onTap: () => _openCalendar(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.kDefaultPadding,
                          vertical: AppSizes.kDefaultPadding / 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackgroundDark.withAlpha(
                            100,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSizes.cardCornerRadius * 5,
                          ),
                        ),
                        child: Text(
                          DateTimeUtils.getFormattedSelectedDate(
                            _selectedDate,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: AppColors.white),
                        ),
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
                  if (state is FetchRouteHistoryStateLoading) {
                    return const Center(
                      child: ThemedActivityIndicator(),
                    );
                  }

                  if (state is FetchRouteHistoryStateFailed) {
                    return Center(
                      child: Text(
                        state.error,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  if (state is FetchRouteHistoryStateLoaded) {
                    final routes = state.routes;
                    if (routes.isEmpty) {
                      return Center(
                        child: Text(
                          'No Route History',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: routes.length,
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.only(
                        left: AppSizes.kDefaultPadding,
                        right: AppSizes.kDefaultPadding,
                        top: AppSizes.kDefaultPadding,
                        bottom: AppSizes.kDefaultPadding * 4,
                      ),
                      itemBuilder: (context, index) {
                        return RouteCard(route: routes[index]);
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        height: AppSizes.kDefaultPadding / 1.5,
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
