class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool emailVerified; // added

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.emailVerified = false, // default false
  });

  // Optional convenience factory if you want to build from Firebase User
  // import 'package:firebase_auth/firebase_auth.dart' to use this factory
  // factory UserModel.fromFirebase(User user) => UserModel(
  //   uid: user.uid,
  //   name: user.displayName ?? '',
  //   email: user.email ?? '',
  //   emailVerified: user.emailVerified,
  // );
  // From Firebase User
  factory UserModel.fromFirebase(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      emailVerified: data['emailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
    };
  }
}
