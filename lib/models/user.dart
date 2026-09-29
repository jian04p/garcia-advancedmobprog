enum LoginType { dummyJson, firebase }

class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    required this.accessToken,
    required this.refreshToken,
    this.age,
    this.contactNo = '',
    this.loginType = LoginType.dummyJson,
    this.firebaseUid = '',
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String accessToken;
  final String refreshToken;
  final int? age;
  final String contactNo;
  final LoginType loginType;
  final String firebaseUid;

  String get fullName => '$firstName $lastName'.trim();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num? ?? 0).toInt(),
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      image: json['image'] as String? ?? '',
      accessToken:
          json['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      age: (json['age'] as num?)?.toInt(),
      contactNo: json['contactNo'] as String? ?? '',
      loginType: json['loginType'] == LoginType.firebase.name
          ? LoginType.firebase
          : LoginType.dummyJson,
      firebaseUid: json['firebaseUid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'age': age,
      'contactNo': contactNo,
      'loginType': loginType.name,
      'firebaseUid': firebaseUid,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? accessToken,
    String? refreshToken,
    int? age,
    String? contactNo,
    LoginType? loginType,
    String? firebaseUid,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      age: age ?? this.age,
      contactNo: contactNo ?? this.contactNo,
      loginType: loginType ?? this.loginType,
      firebaseUid: firebaseUid ?? this.firebaseUid,
    );
  }
}
