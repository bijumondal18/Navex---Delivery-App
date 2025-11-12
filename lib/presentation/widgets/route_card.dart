import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/navigation/screens.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';
import 'package:navex/core/utils/date_time_utils.dart';
import 'package:navex/core/utils/snackbar_helper.dart';
import 'package:navex/presentation/bloc/route_bloc.dart';
import 'package:navex/presentation/widgets/app_text_button.dart';

import '../../data/models/route.dart';

class RouteCard extends StatefulWidget {
  final RouteData? route;
  final RouteBloc? bloc;
  final String? currentDate;

  const RouteCard({
    super.key,
    required this.route,
    this.bloc,
    this.currentDate,
  });

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard> {
  bool _isCancelling = false;

  int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  bool _isAcceptedTrip() {
    final status = _parseToInt(widget.route?.status);
    return status == 3 || status == 4;
  }

  void _handleCancelTrip() async {
    if (widget.route?.id == null || _isCancelling) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
        ),
        title: Text(
          'Cancel Trip',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to cancel this trip? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No',
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorLight,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.bloc != null && mounted) {
      setState(() => _isCancelling = true);
      widget.bloc!.add(CancelRouteEvent(routeId: widget.route!.id.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    if (route == null) return const SizedBox.shrink();

    final isAccepted = _isAcceptedTrip();
    final status = _parseToInt(route.status);
    final primaryColor = Theme.of(context).primaryColor;

    return BlocListener<RouteBloc, RouteState>(
      bloc: widget.bloc,
      listenWhen: (prev, curr) =>
          curr is CancelRouteStateLoading ||
          curr is CancelRouteStateLoaded ||
          curr is CancelRouteStateFailed,
      listener: (context, state) {
        if (state is CancelRouteStateLoading) {
          setState(() => _isCancelling = true);
        } else if (state is CancelRouteStateLoaded) {
          setState(() => _isCancelling = false);
          SnackBarHelper.showSuccess(
            state.response.message ?? 'Trip cancelled successfully',
            context: context,
          );
          // Screen-level BlocListener will handle the refresh
        } else if (state is CancelRouteStateFailed) {
          setState(() => _isCancelling = false);
          SnackBarHelper.showError(state.error, context: context);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (status == 3 || status == 4) {
            appRouter.pushNamed(
              Screens.inRoute,
              pathParameters: {'id': route.id.toString()},
            );
          } else {
            appRouter.pushNamed(
              Screens.tripDetails,
              pathParameters: {'id': route.id.toString()},
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Colored accent bar at top
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with route name and status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route icon with background
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                primaryColor.withOpacity(0.2),
                                primaryColor.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.local_shipping_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Route info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Route name
                              if (route.routeName != null &&
                                  route.routeName.toString().isNotEmpty)
                                Text(
                                  route.routeName.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 6),
                              // Time badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateTimeUtils.convertToAmPm(
                                        route.startTime.toString(),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        if (isAccepted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.greenLight,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status == 4 ? 'In Route' : 'Accepted',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                        color: AppColors.greenDark,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Pickup address section
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location icon
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Address
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pickup Location',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  route.pickupAddress?.toString() ?? 'N/A',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats row - Distance and Time
                    Row(
                      children: [
                        // Distance stat
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: SvgPicture.asset(
                              AppImages.pinRed,
                              width: 20,
                              height: 20,
                            ),
                            label: 'Distance',
                            value: '${route.totalDistance ?? '0'} mi',
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Time stat
                        Expanded(
                          child: _buildStatCard(
                            context,
                            icon: Image.asset(
                              AppImages.timer,
                              width: 20,
                              height: 20,
                            ),
                            label: 'Duration',
                            value: DateTimeUtils.convertMinutesToHoursMinutes(
                              route.totalTime?.toString() ?? '0',
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Cancel Trip button (only for accepted trips)
                    if (isAccepted) ...[
                      const SizedBox(height: 16),
                      AppTextButton(
                        label: 'Cancel Trip',
                        variant: TextBtnVariant.danger,
                        size: TextBtnSize.md,
                        fullWidth: true,
                        leadingIcon: Icons.close_rounded,
                        isLoading: _isCancelling,
                        onPressed: _handleCancelTrip,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required Widget icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
