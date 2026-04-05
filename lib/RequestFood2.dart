import 'package:communityplateproject2/RequestHelper.dart';
import 'package:communityplateproject2/ProfilePage.dart';
import 'package:communityplateproject2/distance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class RequestFood2 extends StatefulWidget {
  const RequestFood2({super.key});

  @override
  State<RequestFood2> createState() => _RequestFood2State();
}

class _RequestFood2State extends State<RequestFood2> {

  String? selectedCategory;

  Future<GeoPoint?> _loadCurrentUserLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!userDoc.exists) return null;

    final data = userDoc.data();
    return data?['location'] as GeoPoint?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Request Food"),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryButton("Fruits"),
                    const SizedBox(width: 8),
                    _buildCategoryButton("Grains"),
                    const SizedBox(width: 8),
                    _buildCategoryButton("Vegetables"),
                    const SizedBox(width: 8),
                    _buildCategoryButton("Snacks"),
                    const SizedBox(width: 8),
                    _buildCategoryButton("Meat"),
                    const SizedBox(width: 8),
                    _buildCategoryButton("Other"),
                  ],
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<GeoPoint?>(
                future: _loadCurrentUserLocation(),
                builder: (context, userLocationSnapshot) {
                  final userLocation = userLocationSnapshot.data;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Donated Food")
                        .snapshots(),
                    builder: (context, snapshot) {
                  // 1. Handle waiting state (first load)
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Handle errors
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  // 3. Handle no data or empty list
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No donations found."));
                  }

                  final docs = snapshot.data!.docs;
                  final filteredDocs = selectedCategory == null
                      ? docs
                      : docs.where((docSnap) {
                          final data = docSnap.data() as Map<String, dynamic>;
                          final type = (data["type"] ?? "").toString().toLowerCase();
                          return type == selectedCategory!.toLowerCase();
                        }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text("No donations found for this category."));
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index].data() as Map<String, dynamic>;
                      final docSnap = filteredDocs[index];
                      final itemLocation = doc["location"] as GeoPoint?;
                      final computedDistance = (userLocation != null && itemLocation != null)
                          ? calculateDistanceMiles(
                              userLocation.latitude,
                              userLocation.longitude,
                              itemLocation.latitude,
                              itemLocation.longitude,
                            )
                          : null;
                      final savedDistance = double.tryParse(doc["distance"]?.toString() ?? "");
                      final distanceToShow = computedDistance ?? savedDistance ?? 0.0;

                      return RequestHelper(
                        id: docSnap.id,
                        donatorUid: doc["requester"] ?? "",
                        foodName: doc["name"]?.toString() ?? "Unknown",
                        image: doc["image"]?.toString() ?? "", // can be empty
                        personName: doc["requesterName"]?.toString() ?? "Anonymous",
                        quantity: doc["quantity"]?.toString() ?? "N/A",
                        distance: double.parse(distanceToShow.toStringAsFixed(1)),
                        type: doc["type"]?.toString() ?? "N/A",
                        expirationDate: DateFormat('MM/dd/yyyy').format(doc["earliestExpirationDate"].toDate()),
                        location: doc["address"]?.toString() ?? "N/A",
                        notes: doc["notes"]?.toString() ?? "",
                      );
                    },
                  );
                    },
                  );
                },
              ),
            ),
          ],
        )
    );
  }

  Widget _buildCategoryButton(String category) {
    final isSelected = selectedCategory == category;
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          isSelected ? Colors.black : Colors.grey[400],
        ),
      ),
      onPressed: () {
        setState(() {
          if (isSelected) {
            selectedCategory = null; // toggle off
          } else {
            selectedCategory = category;
          }
        });
      },
      child: Text(category,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}
