import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:communityplateproject2/LoginPage.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
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
          // Auto-create missing profile
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .set({
            'name': currentUser!.displayName ?? '',
            'email': currentUser!.email ?? '',
            'address': '',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final notifications = List.from(data['notifications'] ?? []);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Your Profile'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      (data['name'] != null && (data['name'] as String).isNotEmpty)
                          ? (data['name'] as String)[0].toUpperCase()
                          : (currentUser?.displayName?.isNotEmpty ?? false)
                          ? currentUser!.displayName![0].toUpperCase()
                          : "?",
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text("Name: ${data['name'] ?? 'No name'}"),
                Text("Email: ${data['email'] ?? currentUser?.email ?? 'No email'}"),
                Text("Address: ${data['address'] ?? 'No address'}"),
                const SizedBox(height: 30),
                Center(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const loginpage()),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Sign Out"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}