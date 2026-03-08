import 'dart:math';
import 'package:communityplateproject2/SearchItem.dart';

double calculateDistanceMiles(
  double lat1,
  double lon1,
  double lat2,
  double lon2
) {
  const earthRadiusMiles = 3958.8;
  final dLat = _degToRad(lat2-lat1);
  final dLon = _degToRad(lon2-lon1);

  final a =
      sin(dLat / 2) * sin(dLat / 2) +
          cos(_degToRad(lat1)) *
              cos(_degToRad(lat2)) *
              sin(dLon / 2) *
              sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusMiles * c;
}

double _degToRad(double deg) => deg * pi / 180;

List<SearchItem> filterByDistance({
  required List<SearchItem> items,
  required double userLat,
  required double userLng,
  double maxMiles = 10,
}) {
  return items.where((item) {
    if (item.lat == null || item.lng == null) return false;

    final distance = calculateDistanceMiles(
      userLat,
      userLng,
      item.lat!,
      item.lng!,
    );

    return distance <= maxMiles;
  }).toList();
}