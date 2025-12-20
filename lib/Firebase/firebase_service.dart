import 'package:communityplateproject2/Firebase/food_request.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:communityplateproject2/LoginPage.dart';
import 'package:communityplateproject2/RegisterPage.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signIn(String email, String password) async {
    try{
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return true;
    } on FirebaseAuthException catch (e) {
      print(e);
      return false;
    }
  }

  Future createNewUser(String email, String password) async {
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch(e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
    }
  }

  Future<String> createFoodRequest(FoodRequest request) async {
    final docRef = await _firestore.collection('Requested Food').add(request.toMap());

    await _firestore.collection('users').doc(request.requester).update({
      'requests' : FieldValue.arrayUnion([docRef.id])
    });

    await _firestore.collection('foodItems').doc(request.name).update({
      'requester' : request.requester
    });

    return docRef.id;
  }

  Future<String> createFoodDonation(FoodRequest donation) async {
    final docRef = await _firestore.collection('Donated Food').add(donation.toMap());

    await _firestore.collection('users').doc(donation.requester).update({
      'donations' : FieldValue.arrayUnion([docRef.id])
    });

    await _firestore.collection('foodItems').doc(donation.name).update({
      'donator' : donation.requester
    });

    return docRef.id;
  }


  Stream<List<FoodRequest>> getUserRequests(String userId) {
    return _firestore
        .collection('requests')
        .where('requester', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FoodRequest.fromFirestore(doc)).toList());
  }

  Stream<List<FoodRequest>> getDonationRequests(String userId) {
    return _firestore
        .collection('requests')
        .where('donor', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FoodRequest.fromFirestore(doc)).toList());
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status' : status
    });

    if(status == 'rejected') {
      final request = await _firestore.collection('requests').doc(requestId).get();
      final data = request.data() as Map<String, dynamic>;
      final foodItemId = data['name'];

      await _firestore.collection('foodItems').doc(foodItemId).update({
        'requester' : null
      });
    }
  }


}

