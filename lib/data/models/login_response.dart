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
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['token'] = this.token;
    data['pharmacy_key'] = this.pharmacyKey;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}


