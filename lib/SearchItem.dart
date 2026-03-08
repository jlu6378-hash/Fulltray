class SearchItem {
  final String id;
  final String name;
  final String type;
  final String quantity;
  final String address;
  final String notes;
  final bool isDonation;

  final double? lat;
  final double? lng;

  SearchItem({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.address,
    required this.notes,
    required this.isDonation,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "type": type,
    "quantity": quantity,
    "notes": notes,
    "kind": isDonation ? "donation" : "request",
    "lat": lat,
    "lng": lng,
  };
}