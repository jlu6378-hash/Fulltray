import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String address;
  final String? phone;
  final String? photo;
  final List<String> donations;
  final List<String> requests;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    this.phone,
    this.photo,
    required this.donations,
    required this.requests,
    required this.createdAt
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      photo: data['photo'] ?? '',
      donations: List<String>.from(data['donations'] ?? []),
      requests: List<String>.from(data['requests'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'email' : email,
      'address' : address,
      'phone' : phone,
      'photo' : photo,
      'donations' : donations,
      'requests' : requests,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}