import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/data/repositories/route_repository.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_picker_utils.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/models/route.dart';
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
  List<RouteData>? _lastLoadedRoutes;

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
      child: BlocListener<RouteBloc, RouteState>(
        listenWhen: (prev, curr) => 
            curr is CancelRouteStateLoaded ||
            curr is FetchAcceptedRoutesStateLoaded,
        listener: (context, state) {
          // When a route is canceled, BLoC emits FetchAcceptedRoutesStateLoaded
          // with the updated list (canceled route removed)
          // Store the updated routes for display
          if (state is FetchAcceptedRoutesStateLoaded) {
            _lastLoadedRoutes = state.routeResponse.route ?? [];
          }
        },
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
                  buildWhen: (previous, current) {
                    // Rebuild for accepted routes states and cancel loaded state
                    // (cancel loaded triggers FetchAcceptedRoutesStateLoaded which updates the list)
                    return current is FetchAcceptedRoutesStateLoading ||
                        current is FetchAcceptedRoutesStateLoaded ||
                        current is FetchAcceptedRoutesStateFailed ||
                        current is CancelRouteStateLoaded;
                  },
                  builder: (context, state) {
                    if (state is FetchAcceptedRoutesStateLoading) {
                      // Show loading only if we don't have previous routes
                      if (_lastLoadedRoutes == null || _lastLoadedRoutes!.isEmpty) {
                        return const Center(
                          child: ThemedActivityIndicator(),
                        );
                      }
                      // If we have previous routes, show them while loading
                      return _buildRoutesList(_lastLoadedRoutes!);
                    }
                    if (state is FetchAcceptedRoutesStateFailed) {
                      // Show error, but keep previous routes if available
                      if (_lastLoadedRoutes != null && _lastLoadedRoutes!.isNotEmpty) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSizes.kDefaultPadding),
                              child: Text(
                                state.error,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(child: _buildRoutesList(_lastLoadedRoutes!)),
                          ],
                        );
                      }
                      return Center(
                        child: Text(
                          state.error,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    if (state is FetchAcceptedRoutesStateLoaded) {
                      final route = state.routeResponse.route ?? [];
                      _lastLoadedRoutes = route; // Store the current routes
                      return _buildRoutesList(route);
                    }
                    // For cancel states or other states, show last loaded routes if available
                    if (_lastLoadedRoutes != null && _lastLoadedRoutes!.isNotEmpty) {
                      return _buildRoutesList(_lastLoadedRoutes!);
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutesList(List<RouteData> routes) {
    final currentDate = DateTimeUtils.getFormattedPickedDate(
      _selectedDate ?? DateTime.now(),
    );
    return routes.isNotEmpty
        ? ListView.separated(
            itemCount: routes.length,
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.only(
              left: AppSizes.kDefaultPadding,
              right: AppSizes.kDefaultPadding,
              top: AppSizes.kDefaultPadding,
              bottom: AppSizes.kDefaultPadding * 4,
            ),
            itemBuilder: (context, index) {
              return RouteCard(
                route: routes[index],
                bloc: _bloc,
                currentDate: currentDate,
              );
            },
            separatorBuilder: (BuildContext context, int index) => const SizedBox(
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
}
