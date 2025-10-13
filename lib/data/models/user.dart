import 'driver.dart';

class User {
  int? id;
  String? name;
  String? email;
  String? profileImage;
  String? emailVerifiedAt;
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
    json['driver'] != null ?  Driver.fromJson(json['driver']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['profile_image'] = profileImage;
    data['email_verified_at'] = emailVerifiedAt;
    data['role'] = role;
    data['status'] = status;
    if (driver != null) {
      data['driver'] = driver!.toJson();
    }
    return data;
  }
}