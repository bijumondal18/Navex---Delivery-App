// import 'package:biztoso/utils/app_utils.dart';
// import 'package:wechat_assets_picker/wechat_assets_picker.dart';

extension ExtString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidPassword {
    return this != null && length >= 6;
  }

  bool get isValidName {
    final nameRegExp =
    RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidString {
    final nameRegExp =
    RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  // bool get isValidPassword {
  //   final passwordRegExp = RegExp(
  //       r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\><*~]).{8,}/pre>');
  //   return passwordRegExp.hasMatch(this);
  // }

  bool get isNotNull {
    return this != null && trim().isNotEmpty;
  }

  bool get isValidPhone {
    final phoneRegExp = RegExp(r"^\+?0[0-9]{10}$");
    return phoneRegExp.hasMatch(this);
  }

  String get capitalizeFirstLetter {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

}


// extension AssetEntityListX on List<AssetEntity> {
//   Future<List<String>> toLocalPaths({bool asUri = false}) =>
//       AppUtils.assetsToPaths(this, asUri: asUri);
// }