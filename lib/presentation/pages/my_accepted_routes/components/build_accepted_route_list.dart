// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:navex/data/repositories/route_repository.dart';
//
// import '../../../../core/themes/app_sizes.dart';
// import '../../../../core/utils/date_time_utils.dart';
// import '../../../bloc/route_bloc.dart';
// import '../../../widgets/route_card.dart';
//
// class BuildAcceptedRouteList extends StatefulWidget {
//   final DateTime? pickedDate;
//
//   const BuildAcceptedRouteList({super.key, this.pickedDate});
//
//   @override
//   State<BuildAcceptedRouteList> createState() => _BuildAcceptedRouteListState();
// }
//
// class _BuildAcceptedRouteListState extends State<BuildAcceptedRouteList> {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<RouteBloc, RouteState>(
//       builder: (context, state) {
//         if (state is FetchAcceptedRoutesStateLoading) {
//           return const Center(child: CircularProgressIndicator.adaptive());
//         }
//         if (state is FetchAcceptedRoutesStateFailed) {
//           return Center(
//             child: Text(
//               state.error,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           );
//         }
//         if (state is FetchAcceptedRoutesStateLoaded) {
//           final route = state.routeResponse.route ?? [];
//           return route.isNotEmpty
//               ? ListView.separated(
//                   itemCount: route.length,
//                   scrollDirection: Axis.vertical,
//                   padding: const EdgeInsets.only(
//                     left: AppSizes.kDefaultPadding,
//                     right: AppSizes.kDefaultPadding,
//                     top: AppSizes.kDefaultPadding,
//                     bottom: AppSizes.kDefaultPadding * 4,
//                   ),
//                   itemBuilder: (context, index) {
//                     return RouteCard(route: route[index]);
//                   },
//                   separatorBuilder: (BuildContext context, int index) =>
//                       const SizedBox(height: AppSizes.kDefaultPadding / 1.5),
//                 )
//               : Center(
//                   child: Text(
//                     'No Accepted Routes',
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                 );
//         }
//         return SizedBox();
//       },
//     );
//   }
// }
