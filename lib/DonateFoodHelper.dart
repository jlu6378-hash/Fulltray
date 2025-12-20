import 'package:flutter/material.dart';
import 'package:communityplateproject2/DonateConfirmation.dart';

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
            ) : type == 'Fruits' ? Image.network(
              'https://res.cloudinary.com/hz3gmuqw6/image/upload/c_fill,h_450,q_auto,w_710/f_auto/wip--21-healthiest-fruits-to-eat-in-2024-php3RGRfc',
              width: 375,
              height: 175,
              fit: BoxFit.cover,
            ) : type == 'Meat' ? Image.network(
              'https://res.cloudinary.com/hz3gmuqw6/image/upload/c_fill,h_450,q_auto,w_710/f_auto/wip--21-healthiest-fruits-to-eat-in-2024-php3RGRfc',
              width: 375,
              height: 175,
              fit: BoxFit.cover,
            ) : type == 'Grains' ? Image.network('https://www.eatright.org/-/media/images/eatright-landing-pages/grainslp_804x482.jpg?h=482&w=804&rev=d44c22d03d0b452a9e266ff827d25534&hash=C170BE6A1B67C3A04A27A2F1A906E568',
              width: 375,
              height: 175,
              fit: BoxFit.cover
            ) : type == 'Vegetables' ? Image.network('https://cdn.britannica.com/17/196817-159-9E487F15/vegetables.jpg',
                width: 375,
                height: 175,
                fit: BoxFit.cover
            ) : type == 'Snacks' ? Image.network('https://media.theeverymom.com/wp-content/uploads/2023/08/22105814/healthy-after-school_snacks-banana-sushi-rolls-the-everymom11.jpg',
                width: 375,
                height: 175,
                fit: BoxFit.cover
            ) : type == 'Other' ? Image.network('ttps://www.shutterstock.com/image-photo/assortment-baked-goods-displayed-on-600nw-2575371219.jpg',
                width: 375,
                height: 175,
                fit: BoxFit.cover
            ) : Image.asset('assets/images/placeholder.png',
              width: 375,
              height: 175,
              fit: BoxFit.cover)
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
