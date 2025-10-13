import 'driver.dart';

class User {
  int? id;
  String? name;
  String? email;
  String? profileImage;
  Null? emailVerifiedAt;
  int? role;
  String? status;
  Driver? driver;

  User(
      {this.id,
        this.name,
        this.email,
        this.profileImage,
        this.emailVerifiedAt,
        this.role,
        this.status,
        this.driver});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    profileImage = json['profile_image'];
    emailVerifiedAt = json['email_verified_at'];
    role = json['role'];
    status = json['status'];
    driver =
    json['driver'] != null ? new Driver.fromJson(json['driver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['profile_image'] = this.profileImage;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['role'] = this.role;
    data['status'] = this.status;
    if (this.driver != null) {
      data['driver'] = this.driver!.toJson();
    }
    return data;
  }
}