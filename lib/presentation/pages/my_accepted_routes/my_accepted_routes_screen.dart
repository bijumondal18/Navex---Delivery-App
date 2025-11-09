import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/data/repositories/route_repository.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_picker_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../bloc/route_bloc.dart';
import '../../widgets/route_card.dart';
import '../../widgets/themed_activity_indicator.dart';

class MyAcceptedRoutesScreen extends StatefulWidget {
  const MyAcceptedRoutesScreen({super.key});

  @override
  State<MyAcceptedRoutesScreen> createState() => _MyAcceptedRoutesScreenState();
}

class _MyAcceptedRoutesScreenState extends State<MyAcceptedRoutesScreen> {
  DateTime? _selectedDate;
  late final RouteBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = RouteBloc(RouteRepository())
      ..add(
        FetchAcceptedRoutesEvent(
          date: DateTimeUtils.getFormattedPickedDate(DateTime.now()),
        ),
      );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _openCalendar() async {
    final pickedDate = await showAppDatePicker(
      context: context,
      barrierDismissible: false,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
      _bloc.add(
        FetchAcceptedRoutesEvent(
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
                      'Accepted Routes',
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
                            _selectedDate ?? DateTime.now(),
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
                  if (state is FetchAcceptedRoutesStateLoading) {
                    return const Center(
                      child: ThemedActivityIndicator(),
                    );
                  }
                  if (state is FetchAcceptedRoutesStateFailed) {
                    return Center(
                      child: Text(
                        state.error,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  if (state is FetchAcceptedRoutesStateLoaded) {
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
                              'No Accepted Routes',
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
      ),
    );
  }
}
