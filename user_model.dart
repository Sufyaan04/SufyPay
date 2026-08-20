class UserModel {
  final String uid;
  final String name;
  final String email;
  final double balance;
  final String upiId;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.balance,
    required this.upiId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'balance': balance,
      'upiId': upiId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      balance: (map['balance'] ?? 0).toDouble(),
      upiId: map['upiId'] ?? '',
    );
  }
}