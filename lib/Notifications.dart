import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final DateFormat _fmt = DateFormat('MM/dd/yyyy hh:mm a');

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Profile')),
        body: const Center(child: Text('No user is signed in.')),
      );
    }

    final userDocRef =
    FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDocRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Notifications')),
            body: const Center(child: Text("User profile not found.")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final notifications = List.from(data['notifications'] ?? []);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Notifications",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: notifications.isEmpty
                      ? const Center(child: Text("No notifications yet"))
                      : ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final raw = notifications[index];
                      if (raw == null) return const SizedBox.shrink();
                      final notif = Map<String, dynamic>.from(raw as Map);

                      String message = notif['message'] ?? '';
                      String pickupStr = 'Pickup: N/A';
                      String sentStr = '';

                      // Convert pickupTime if it's a Timestamp
                      try {
                        if (notif['pickupTime'] != null) {
                          final p = notif['pickupTime'];
                          DateTime pdt = p is Timestamp
                              ? p.toDate()
                              : DateTime.parse(p.toString());
                          pickupStr = "Pickup: ${_fmt.format(pdt)}";
                        }
                      } catch (_) {}

                      // Convert timestamp if it's a Timestamp
                      try {
                        if (notif['timestamp'] != null) {
                          final t = notif['timestamp'];
                          DateTime tdt = t is Timestamp
                              ? t.toDate()
                              : DateTime.parse(t.toString());
                          sentStr = "Sent: ${_fmt.format(tdt)}";
                        }
                      } catch (_) {}

                      return ListTile(
                        leading: const Icon(Icons.notifications),
                        title: Text(message),
                        subtitle: Text(
                            [pickupStr, sentStr].where((s) => s.isNotEmpty).join('\n')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
