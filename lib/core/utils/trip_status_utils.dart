class TripStatusHelper {
  TripStatusHelper._();

  static const Map<int, String> _statusLabels = {
    0: 'Pending',
    1: 'Draft Routes',
    2: 'Upcoming Routes',
    3: 'Accepted',
    4: 'Inroute',
    5: 'Finished',
    6: 'Canceled Route',
  };

  static String getStatusLabel(int? status) {
    if (status == null) {
      return 'Unknown';
    }
    return _statusLabels[status] ?? 'Unknown';
  }

  static bool canEnableCheckIn(int? status) {
    if (status == null) return false;
    return status == 3;
  }

  static bool isAlreadyCheckedIn(int? status) {
    if (status == null) return false;
    return status == 4 || status == 5 || status == 6;
  }
}

