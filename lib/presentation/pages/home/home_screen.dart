import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/date_time_utils.dart';
import 'package:navex/presentation/widgets/route_card.dart';
import 'package:navex/presentation/widgets/themed_activity_indicator.dart';

import '../../bloc/auth_bloc.dart';
import '../../bloc/route_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isFlagTrue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == '1' || normalized == 'true';
    }
    return false;
  }

  bool _getIsOnline(AuthState state) {
    if (state is FetchUserProfileStateLoaded) {
      final driver = state.profileResponse.user?.driver;
      if (driver != null) {
        // Access isOnline from Driver model (dynamic field)
        final isOnlineValue = (driver as dynamic).isOnline;
        return _isFlagTrue(isOnlineValue);
      }
    }
    return false;
  }

  void _fetchRoutesIfOnline() {
    final authState = context.read<AuthBloc>().state;
    final isOnline = _getIsOnline(authState);
    if (isOnline) {
      context.read<RouteBloc>().add(
            FetchUpcomingRoutesEvent(
              date: DateTimeUtils.getFormattedPickedDate(DateTime.now()),
            ),
          );
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch profile to get online status
    context.read<AuthBloc>().add(FetchUserProfileEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // When screen becomes visible again, check if routes need to be fetched
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeState = context.read<RouteBloc>().state;
      final authState = context.read<AuthBloc>().state;
      final isOnline = _getIsOnline(authState);
      
      // If user is online but routes are not loaded, fetch them
      if (isOnline && routeState is! FetchUpcomingRoutesStateLoaded) {
        _fetchRoutesIfOnline();
      }
    });
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
            child: MultiBlocListener(
              listeners: [
                BlocListener<AuthBloc, AuthState>(
                  listenWhen: (prev, curr) {
                    // Listen when profile is loaded or online status changes
                    if (curr is FetchUserProfileStateLoaded) {
                      // On initial load or when online status changes
                      if (prev is! FetchUserProfileStateLoaded) return true;
                      final prevIsOnline = _getIsOnline(prev);
                      final currIsOnline = _getIsOnline(curr);
                      return prevIsOnline != currIsOnline;
                    }
                    if (curr is UpdateOnlineOfflineStatusStateLoaded) return true;
                    return false;
                  },
                  listener: (context, state) {
                    if (state is FetchUserProfileStateLoaded) {
                      final isOnline = _getIsOnline(state);
                      if (isOnline) {
                        // Fetch routes when user is online (initial load or status change)
                        context.read<RouteBloc>().add(
                              FetchUpcomingRoutesEvent(
                                date: DateTimeUtils.getFormattedPickedDate(
                                  DateTime.now(),
                                ),
                              ),
                            );
                      }
                    } else if (state is UpdateOnlineOfflineStatusStateLoaded) {
                      // Refresh profile to get updated online status
                      context.read<AuthBloc>().add(FetchUserProfileEvent());
                    }
                  },
                ),
              ],
              child: BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (prev, curr) {
                  // Rebuild when profile is loading or when online status changes
                  if (curr is FetchUserProfileStateLoading) return true;
                  if (curr is FetchUserProfileStateLoaded) {
                    // On initial load, prev might be AuthInitial, so always rebuild
                    if (prev is! FetchUserProfileStateLoaded) return true;
                    final prevIsOnline = _getIsOnline(prev);
                    final currIsOnline = _getIsOnline(curr);
                    return prevIsOnline != currIsOnline;
                  }
                  return false;
                },
                builder: (context, authState) {
                  // Show loading while profile is being fetched
                  if (authState is FetchUserProfileStateLoading ||
                      authState is AuthInitial) {
                    return const Center(
                      child: ThemedActivityIndicator(),
                    );
                  }

                  // Get online status from auth state
                  final isOnline = _getIsOnline(authState);

                  // Show offline message if user is offline
                  if (!isOnline) {
                    return Center(
                      child: Text(
                        'Please go online to take request',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Show routes list if user is online
                  return BlocBuilder<RouteBloc, RouteState>(
                    buildWhen: (prev, curr) {
                      // Rebuild when routes state changes
                      return curr is FetchUpcomingRoutesStateLoading ||
                          curr is FetchUpcomingRoutesStateLoaded ||
                          curr is FetchUpcomingRoutesStateFailed;
                    },
                    builder: (context, state) {
                      if (state is FetchUpcomingRoutesStateLoading) {
                        return const Center(
                          child: ThemedActivityIndicator(),
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
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                              );
                      }
                      // If routes are not loaded yet, check if we need to fetch them
                      final routeBlocState = context.read<RouteBloc>().state;
                      if (routeBlocState is! FetchUpcomingRoutesStateLoaded &&
                          routeBlocState is! FetchUpcomingRoutesStateLoading) {
                        // Routes not loaded, fetch them
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _fetchRoutesIfOnline();
                        });
                      }
                      return const Center(
                        child: ThemedActivityIndicator(),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
