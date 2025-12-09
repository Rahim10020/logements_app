import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour les utilisateurs
/// Contient toutes les informations du profil utilisateur
class UserModel {
  final String id;
  final String uid; // Firebase Auth UID
  final String email;
  final String displayName;
  final String role; // 'tenant', 'owner', 'both'
  final String city;
  final String phone;
  final String photoURL;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.city,
    required this.phone,
    required this.photoURL,
    required this.createdAt,
  });

  /// Créer un UserModel depuis un document Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: json['role'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      photoURL: json['photoURL'] ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convertir le UserModel en Map pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'city': city,
      'phone': phone,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Créer un UserModel depuis un document Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? '',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      photoURL: data['photoURL'] ?? '',
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convertir le UserModel en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Créer une copie du modèle avec des champs modifiés
  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? displayName,
    String? role,
    String? city,
    String? phone,
    String? photoURL,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Vérifier si l'utilisateur est propriétaire
  bool get isOwner => role == 'owner' || role == 'both';

  /// Vérifier si l'utilisateur est locataire
  bool get isTenant => role == 'tenant' || role == 'both';

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, role: $role)';
  }
}
