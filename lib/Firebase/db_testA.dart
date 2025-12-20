import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class db_testA extends StatefulWidget {
  const db_testA({super.key});

  @override
  State<db_testA> createState() => _db_testAState();
}

class _db_testAState extends State<db_testA> {
  final db = FirebaseFirestore.instance;

  final fooditem = <String, dynamic> {
    "Quantity" : 5,
  };
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget> [
            TextField(
              decoration: InputDecoration(helperText: "Doc Name"),
              onSubmitted: (String submittedText) {
                /*
                db.collection("Food").add(fooditem);
                final doc = db.collection("Food").doc("Bread");
                doc.get().then(
                    (DocumentSnapshot d) {
                      final data = d.data() as Map<String, dynamic>?;
                      print(data);
                    },
                    onError: (e) => print("Error loading document $e")
                );

                db.collection("Food")
                  .where("Quantity", isEqualTo: 5)
                  .get().then(
                (querySnapshot) {
                  for (var docSnapshot in querySnapshot.docs) {
                    Map<String, dynamic> q = docSnapshot.data();
                    print(q);
                    }
                  },
                  onError: (e) => print("Error")
                );

                final docRef = db.collection("Food").doc("Bread");
                docRef.update({"Quantity" : 7});

                docRef.delete();*/



                final doc = db.collection("Food").doc("requestTest");
                doc.get().then(
                        (DocumentSnapshot d) {
                      final data = d.data() as Map<String, dynamic>?;
                      print(data);
                    },
                    onError: (e) => print("Error loading document $e")
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
