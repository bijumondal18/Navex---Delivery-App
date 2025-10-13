import 'package:navex/data/models/user.dart';

class LoginResponse {
  bool? status;
  String? message;
  String? token;
  String? pharmacyKey;
  User? user;

  LoginResponse(
      {this.status, this.message, this.token, this.pharmacyKey, this.user});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    pharmacyKey = json['pharmacy_key'];
    user = json['user'] != null ?  User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['token'] = token;
    data['pharmacy_key'] = pharmacyKey;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}


