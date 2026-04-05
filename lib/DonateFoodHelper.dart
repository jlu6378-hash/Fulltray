import 'package:flutter/material.dart';
import 'package:communityplateproject2/DonateConfirmation.dart';
import 'package:communityplateproject2/category_images.dart';

class DonateHelper extends StatelessWidget {
  final String id; // requestId
  final String requesterUid;
  final String foodName;
  final String image;
  final String personName;
  final String quantity;
  final double distance;
  final String type;
  final String expirationDate;
  final String location;
  final String notes;

  const DonateHelper({
    super.key,
    required this.id,
    required this.requesterUid,
    required this.foodName,
    required this.image,
    required this.personName,
    required this.quantity,
    required this.distance,
    required this.type,
    required this.expirationDate,
    required this.location,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white10,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: image.isNotEmpty
                ? Image.network(
              image,
              width: 375,
              height: 175,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder.png',
                  width: 375,
                  height: 175,
                  fit: BoxFit.cover,
                );
              },
            ) : Image.network(
              categoryImageUrl(type),
              width: 375,
              height: 175,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder.png',
                  width: 375,
                  height: 175,
                  fit: BoxFit.cover,
                );
              },
            )
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const SizedBox(width: 16),
              Text(foodName, style: const TextStyle(color: Colors.black, fontSize: 15)), //changed !!!!!!!!!!!!!!!!
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const SizedBox(width: 15),
              Icon(Icons.numbers, color: Colors.grey[600], size: 20),
              const SizedBox(width: 3),
              Text(quantity, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
              const SizedBox(width: 15),
              Icon(Icons.pin_drop_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 3),
              Text("$distance miles", style: TextStyle(color: Colors.grey[600], fontSize: 15)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(personName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                SizedBox(
                  height: 32,
                  width: 80,
                  child: FilledButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: const Text("Donate", style: TextStyle(color: Colors.white, fontSize: 15)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DonateConfirmation(
                            requestId: id,
                            requesterUid: requesterUid

                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text('More details'),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Type: $type'),
                    Text('Earliest expiration date: $expirationDate'),
                    Text('Location: $location'),
                    Text('Notes: $notes'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
