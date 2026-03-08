import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communityplateproject2/SearchItem.dart';

class FoodItem {
  final String id;
  final String name;
  final String type;
  final String quantity;
  final DateTime expirationDate;
  final String address;
  final String? notes;
  final String donor;
  final String? requester;
  final String? image;
  final DateTime createdAt;
  final GeoPoint? location;

  FoodItem({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.expirationDate,
    required this.address,
    this.notes,
    required this.donor,
    this.requester,
    this.image,
    required this.createdAt,
    this.location,
  });

  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodItem(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      quantity: data['quantity'] ?? '',
      expirationDate: (data['expirationDate'] as Timestamp).toDate(),
      address: data['address'] ?? '',
      notes: data['notes'],
      donor: data['donor'] ?? '',
      requester: data['requester'],
      image: data['image'],
      location: data['location'], // GeoPoint
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  SearchItem fromFoodItem(FoodItem item) {
    return SearchItem(
      id: item.id,
      name: item.name,
      type: item.type,
      quantity: item.quantity,
      address: item.address,
      notes: item.notes ?? '',
      isDonation: true,
      lat: item.location?.latitude,
      lng: item.location?.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name' : name,
      'type' : type,
      'quantity' : quantity,
      'expirationDate' : expirationDate,
      'address' : address,
      'notes' : notes,
      'donor' : donor,
      'requester' : requester,
      'image' : image,
      'createdAt' : createdAt,
      'location' : location
    };
  }
}