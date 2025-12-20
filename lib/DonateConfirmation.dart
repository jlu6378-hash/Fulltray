import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonateConfirmation extends StatefulWidget {
  final String requestId;
  final String requesterUid;

  const DonateConfirmation({
    super.key,
    required this.requestId,
    required this.requesterUid,
  });

  @override
  State<DonateConfirmation> createState() => _DonateConfirmationState();
}

class _DonateConfirmationState extends State<DonateConfirmation> {
  DateTime? _selectedDateTime;
  bool _saving = false;

  Future<Map<String, dynamic>?> _fetchRequesterData() async {
    try {
      final requestDoc = await FirebaseFirestore.instance
          .collection('Requested Food')
          .doc(widget.requestId)
          .get();

      if (!requestDoc.exists) return null;
      final requestData = requestDoc.data()!;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.requesterUid)
          .get();

      return {
        'foodName': requestData['name'] ?? '',
        'quantity': requestData['quantity'] ?? '',
        'notes': requestData['notes'] ?? '',
        'requesterName': userDoc.exists ? (userDoc.data()!['name'] ?? 'Unknown') : 'Unknown',
        'requesterEmail': userDoc.exists ? (userDoc.data()!['email'] ?? '') : '',
        'requesterAddress': userDoc.exists ? (userDoc.data()!['address'] ?? '') : '',
      };
    } catch (e) {
      print("Error fetching requester data: $e");
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

  Future<void> _confirmDonation() async {
    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a pickup date & time")),
      );
      return;
    }

    setState(() => _saving = true);

    final pickupTimestamp = Timestamp.fromDate(_selectedDateTime!);
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.requesterUid);
    final requestDocRef = FirebaseFirestore.instance.collection('Requested Food').doc(widget.requestId);

    try {
      // update the request doc (if request doc missing this will throw — catch below)
      await requestDocRef.update({
        'status': 'donated',
        'pickupTime': pickupTimestamp,
      });

      // add notification to the user's notifications array
      // Use set(..., SetOptions(merge: true)) to create the doc if it doesn't exist
      await userDocRef.set({
        'notifications': FieldValue.arrayUnion([
          {
            'message': 'Your donation request has been confirmed!',
            'pickupTime': pickupTimestamp,
            'timestamp': Timestamp.now(),
            'requestId': widget.requestId,
          }
        ])
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation Confirmed")),
      );
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      print("Error confirming donation: $e\n$st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error confirming donation: $e")),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Donation"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchRequesterData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Could not load requester info"));
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
                Text("Requester: ${data['requesterName']}"),
                Text("Email: ${data['requesterEmail']}"),
                Text("Address: ${data['requesterAddress']}"),
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
                    onPressed: _saving ? null : _confirmDonation,
                    child: _saving ? const CircularProgressIndicator() : const Text("Confirm Donation"),
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

/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:communityplateproject2/Firebase/food_request.dart';

class DonateConfirmation extends StatefulWidget {
  final FoodRequest foodRequest;

  const DonateConfirmation({super.key, required this.foodRequest});

  @override
  State<DonateConfirmation> createState() => _DonateConfirmationState();
}

class _DonateConfirmationState extends State<DonateConfirmation> {
  Map<String, dynamic>? requesterData;
  DateTime? selectedPickup;

  @override
  void initState() {
    super.initState();
    _loadRequester();
  }

  Future<void> _loadRequester() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.foodRequest.requester) // requester UID
          .get();

      if (doc.exists) {
        setState(() {
          requesterData = doc.data();
        });
      }
    } catch (e) {
      debugPrint("Error loading requester: $e");
    }
  }

  Future<void> _confirmDonation() async {
    if (selectedPickup == null) return;

    try {
      // push notification into requester's document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.foodRequest.requester)
          .update({
        'notifications': FieldValue.arrayUnion([
          {
            'message':
            'A donor has committed to your request for ${widget.foodRequest.name}.',
            'pickupTime': selectedPickup!.toIso8601String(),
            'createdAt': DateTime.now().toIso8601String(),
          }
        ])
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation confirmed!')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error confirming donation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = requesterData;

    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Donation")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Food Requested: ${widget.foodRequest.name}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Quantity: ${widget.foodRequest.quantity}"),
            const SizedBox(height: 10),
            Text("Type: ${widget.foodRequest.type}"),
            const Divider(height: 30),

            Text("Requester Info:",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (r == null)
              const Text("Loading requester info...")
            else ...[
              Text("Name: ${r['name'] ?? 'Unknown'}"),
              Text("Email: ${r['email'] ?? 'No email'}"),
              Text("Address: ${r['address'] ?? 'No address'}"),
            ],

            const Divider(height: 30),
            const Text("Select Pickup Date & Time:",
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
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

                final combined = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );

                setState(() {
                  selectedPickup = combined;
                });
              },
              child: const Text("Pick Date & Time"),
            ),

            if (selectedPickup != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Pickup scheduled: ${DateFormat.yMd().add_jm().format(selectedPickup!)}",
                ),
              ),

            const Spacer(),
            Center(
              child: FilledButton.icon(
                onPressed: _confirmDonation,
                icon: const Icon(Icons.check),
                label: const Text("Confirm Donation"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
*/