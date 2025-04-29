// ignore_for_file: file_names

class UserModel {
  final String uId;
  final String username;
  final String email;
  final String userDeviceToken;
  final bool isAdmin;
  final bool isActive;
  final dynamic createdOn;
  final String? city;

  UserModel({
    required this.uId,
    required this.username,
    required this.email,
    required this.userDeviceToken,
    required this.isAdmin,
    required this.isActive,
    required this.createdOn,
    this.city,
  });

  // Serialize the UserModel instance to a JSON map
  Map<String, dynamic> toMap() {
    return {
      'uId': uId,
      'username': username,
      'email': email,
      'userDeviceToken': userDeviceToken,
      'isAdmin': isAdmin,
      'isActive': isActive,
      'createdOn': createdOn,
      'city': city,
    };
  }

  // Create a UserModel instance from a JSON map
  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'],
      username: json['username'],
      email: json['email'],
      userDeviceToken: json['userDeviceToken'],
      isAdmin: json['isAdmin'],
      isActive: json['isActive'],
      createdOn: json['createdOn'].toString(),
      city: json['city'],
    );
  }
}
