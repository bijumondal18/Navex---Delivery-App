import 'package:navex/data/models/user.dart';

class ProfileResponse {
  bool? status;
  User? user;

  ProfileResponse({this.status, this.user});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    user = json['user'] != null ?  User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['status'] = status;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}