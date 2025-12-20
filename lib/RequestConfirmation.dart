import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestConfirmation extends StatefulWidget {
  final String donationId;
  final String donatorUid;

  const RequestConfirmation({
    super.key,
    required this.donationId,
    required this.donatorUid
  });

  @override
  State<RequestConfirmation> createState() => _RequestConfirmationState();
}

class _RequestConfirmationState extends State<RequestConfirmation> {
  DateTime? _selectedDateTime;
  bool _saving = false;

  Future<Map<String, dynamic>?> _fetchDonatorData() async {
    try {
      final donationDoc = await FirebaseFirestore.instance
          .collection('Donated Food')
          .doc(widget.donationId)
          .get();

      if (!donationDoc.exists) return null;
      final donationData = donationDoc.data()!;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.donatorUid)
          .get();

      return {
        'foodName': donationData['name'] ?? '',
        'quantity': donationData['quantity'] ?? '',
        'notes': donationData['notes'] ?? '',
        'donorName': userDoc.exists ? (userDoc.data()!['name'] ?? 'Unknown') : 'Unknown',
        'donorEmail': userDoc.exists ? (userDoc.data()!['email'] ?? '') : '',
        'donorAddress': userDoc.exists ? (userDoc.data()!['address'] ?? '') : '',
      };
    } catch (e) {
      print("Error fetching donor data: $e");
      return null;
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _confirmRequest() async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a pickup date & time")),
      );
      return;
    }

    setState(() => _saving = true);

    final pickupTimestamp = Timestamp.fromDate(_selectedDateTime!);
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.donatorUid);
    final donationDocRef = FirebaseFirestore.instance.collection('Donated Food').doc(widget.donationId);

    try {
      // update the request doc (if request doc missing this will throw — catch below)
      await donationDocRef.update({
        'status': 'requested',
        'pickupTime': pickupTimestamp,
      });

      // add notification to the user's notifications array
      // Use set(..., SetOptions(merge: true)) to create the doc if it doesn't exist
      await userDocRef.set({
        'notifications': FieldValue.arrayUnion([
          {
            'message': 'Your request has been confirmed!',
            'pickupTime': pickupTimestamp,
            'timestamp': Timestamp.now(),
            'requestId': widget.donationId,
          }
        ])
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Confirmed")),
      );
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      print("Error confirming request: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error confirming request: $e")),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Request"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchDonatorData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Could not load donor info"));
          }

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Food Item: ${data['foodName']}"),
                Text("Quantity: ${data['quantity']}"),
                Text("Notes: ${data['notes']}"),
                const SizedBox(height: 20),
                Text("Donor: ${data['donorName']}"),
                Text("Email: ${data['donorEmail']}"),
                Text("Address: ${data['donorAddress']}"),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDateTime == null
                            ? "No pickup time selected"
                            : "Pickup: ${_selectedDateTime!.toLocal().toString()}",
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickDateTime,
                      child: const Text("Select Time"),
                    ),
                  ],
                ),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _confirmRequest,
                    child: _saving ? const CircularProgressIndicator() : const Text("Confirm Request"),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
