// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String displayName;
  final List<String> selectedGenres;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.selectedGenres,
  });

  // Convert to map for saving to Firestore (or any DB)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'selectedGenres': selectedGenres,
    };
  }

  // Factory constructor for creating a UserModel from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      selectedGenres: List<String>.from(map['selectedGenres'] ?? []),
    );
  }
}
