import 'package:cloud_firestore/cloud_firestore.dart';

class FoodRequest {
  final String id;
  final String name;
  final String type;
  final String quantity;
  final DateTime earliestExpirationDate;
  final DateTime? pickupTime;
  final String address;
  final String? notes;
  final String requesterName;
  final String requester; // UID of the requester
  final DateTime createdAt;

  FoodRequest({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.earliestExpirationDate,
    this.pickupTime,
    required this.address,
    this.notes,
    required this.requesterName,
    required this.requester,
    required this.createdAt,
  });

  factory FoodRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodRequest(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      quantity: data['quantity'] ?? '',
      earliestExpirationDate: (data['earliestExpirationDate'] as Timestamp).toDate(),
      pickupTime: data['pickupTime'] != null
          ? (data['pickupTime'] as Timestamp).toDate()
          : null,
      address: data['address'] ?? '',
      notes: data['notes'] ?? '',
      requesterName: data['requesterName'] ?? '',
      requester: data['requester'] ?? '', // UID
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'quantity': quantity,
      'earliestExpirationDate': earliestExpirationDate,
      'pickupTime': pickupTime,
      'address': address,
      'notes': notes,
      'requesterName' : requesterName,
      'requester': requester, // UID
      'createdAt': createdAt,
    };
  }
}