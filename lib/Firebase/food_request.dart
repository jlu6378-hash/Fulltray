import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communityplateproject2/SearchItem.dart';

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
  final GeoPoint? location;

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
    this.location,
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
      location: data['location'],
    );
  }

  SearchItem fromFoodRequest(FoodRequest req) {
    return SearchItem(
      id: req.id,
      name: req.name,
      type: req.type,
      quantity: req.quantity,
      address: req.address,
      notes: req.notes ?? '',
      isDonation: false,
      lat: req.location?.latitude,
      lng: req.location?.longitude,
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
      'location': location,
    };
  }
}