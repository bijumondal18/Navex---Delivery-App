import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navex/presentation/pages/home/components/build_upcoming_route_list.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../data/repositories/route_repository.dart';
import '../../bloc/route_bloc.dart';
import '../../widgets/route_card.dart';

class AvailableRoutesScreen extends StatefulWidget {
  const AvailableRoutesScreen({super.key});

  @override
  State<AvailableRoutesScreen> createState() => _AvailableRoutesScreenState();
}

class _AvailableRoutesScreenState extends State<AvailableRoutesScreen> {
  DateTime? _selectedDate;

  Future<void> _openCalendar() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      barrierDismissible: false,
      initialDate: _selectedDate ?? DateTime.now(),
      // current date
      firstDate: DateTime.now(),
      // no previous date allowed
      lastDate: DateTime(2100), // latest date allowed
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RouteBloc(RouteRepository()),
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
                      'Available Routes',
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
                              ) ??
                              DateTimeUtils.getFormattedCurrentDate(),
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
              child: BuildUpcomingRouteList(pickedDate: _selectedDate),
            ),
          ],
        ),
      ),
    );
  }
}
