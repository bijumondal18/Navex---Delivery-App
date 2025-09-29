import 'package:go_router/go_router.dart';

import '../../core/navigation/screens.dart';

class NotificationRouter {
  static void routeFromData(GoRouter router, Map<String, dynamic> data) {
    // Example payload:
    // data: { "type": "trip", "tripId": "abc123" }
    final type = data['type'] as String?;
    switch (type) {
      case 'trip':
        final id = data['tripId']?.toString();
        if (id != null) {
          router.push('${Screens.tripDetails}/$id'); // e.g. /trip/abc123
        } else {
          router.go(Screens.main);
        }
        break;
      case 'available_routes':
        router.go(Screens.availableRoutes);
        break;
      case 'accepted_routes':
        router.go(Screens.acceptedRoutes);
        break;
      case 'route_history':
        router.go(Screens.routeHistory);
        break;
      case 'settings':
        router.go(Screens.settings);
        break;
      default:
        router.go(Screens.main);
    }
  }
}
