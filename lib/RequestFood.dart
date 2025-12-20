import 'dart:math';

import 'package:communityplateproject2/Firebase/db_testA.dart';
import 'package:communityplateproject2/ProfilePage.dart';
import 'package:communityplateproject2/RequestFood2.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:communityplateproject2/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:communityplateproject2/Firebase/firebase_service.dart';
import 'Firebase/food_request.dart';
import 'Firebase/food_item.dart';

class requestFood extends StatefulWidget {
  final FoodItem foodItem;

  const requestFood({super.key, required this.foodItem
  });

  @override
  State<requestFood> createState() => _requestFoodState();
}

final db = FirebaseFirestore.instance;
final fooditem = <String, dynamic> {};

Future<bool> requestFoodItem(String type, String quantity, String expiration, String address, String notes) async {
  fooditem["Type"] = type;
  fooditem["Quantity"] = quantity;
  fooditem["Expiration Date"] = expiration;
  fooditem["Address"] = address;
  fooditem["Notes"] = notes;

  try{
    db.collection("Requested Food").add(fooditem);
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}



class _requestFoodState extends State<requestFood> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); //TBR
  String? _selectedType;
  final _quantityController = TextEditingController();
  final _expirationController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  DateTime _selectedPickupTime = DateTime.now().add(const Duration(hours: 1));
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectPickupTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedPickupTime,
      firstDate: DateTime.now(),
      lastDate: widget.foodItem.expirationDate,
    );

    if(pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedPickupTime),
      );

      if(pickedTime != null) {
        setState(() {
          _selectedPickupTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute
          );
        });
      }
    }
  }

  Future<void> _requestFood() async {
    if(_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to request food')),
          );
          return; // stop execution
        }

        if (_selectedType == null) { // guard
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a food type')),
          );
          return;
        }

        final request = FoodRequest(
            id: '',
            name: _nameController.text,
            type: _selectedType!,
            requesterName: currentUser.displayName ?? currentUser.email ?? "Unknown",
            requester: FirebaseAuth.instance.currentUser!.uid,
            //donor: widget.foodItem.donor,
            quantity: _quantityController.text,
            pickupTime: _selectedPickupTime,
            //status: 'pending',
            createdAt: DateTime.now(),
            address: _addressController.text,
            earliestExpirationDate: DateTime.parse(_expirationController.text), //MUST BE IN yyyy-MM-dd format
            notes: _notesController.text
        );

        _firebaseService.createFoodRequest(request);

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request sent successfully')),
          );
          Navigator.pop(context);
        }
      } catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        if(mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  List<String> categories = ["Fruits", "Grains", "Vegetables", "Snacks", "Meat", "Other"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Request food'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.person, size: 30,),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const profile()));
              },
            ),
          ]
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          //padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                width: 360,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map((category) {
                    final isSelected = _selectedType == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: FilledButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(isSelected ? Colors.black : Colors.grey.shade300),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              )
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedType = category;
                          });
                        },
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 15
                          )
                        )
                      )
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 25,),
                  Text(
                    'Food Name',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      //letterSpacing: 1.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 5,),
              SizedBox(
                  width: 350,
                  height: 45,
                  child: Expanded(
                    child: TextField(
                      controller: _nameController,
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: "Bread, pasta, rice, etc.",

                      ),
                      // onChanged: (String newEntry){
                      //   print("Password entered");
                      // },
                    ),
                  )
              ),
              SizedBox(height:15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 25,),
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      //letterSpacing: 1.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 5,),
              SizedBox(
                  width: 350,
                  height: 45,
                  child: Expanded(
                    child: TextField(
                      controller: _quantityController,
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: "E.g. three loaves of bread",
                      ),
                      // onChanged: (String newEntry){
                      //   print("Password entered");
                      // },
                    ),
                  )
              ),
              SizedBox(height:15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 25,),
                  Text(
                    'Earliest Expiration Date',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      //letterSpacing: 1.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 5,),
              SizedBox(
                  width: 350,
                  height: 45,
                  child: Expanded(
                    child: TextField(
                      controller: _expirationController,
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: "YYYY-MM-DD",
                      ),
                      // onChanged: (String newEntry){
                      //   print("Password entered");
                      // },
                    ),
                  )
              ),
              SizedBox(height:15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 25,),
                  Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      //letterSpacing: 1.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 5,),
              SizedBox(
                  width: 350,
                  height: 45,
                  child: Expanded(
                    child: TextField(
                      controller: _addressController,
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: "E.g. 123 Main Street",
                      ),
                      // onChanged: (String newEntry){
                      //   print("Password entered");
                      // },
                    ),
                  )
              ),
              SizedBox(height:15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 25,),
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      //letterSpacing: 1.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 5,),
              SizedBox(
                  width: 350,
                  height: 100,
                  child: Expanded(
                    child: TextField(
                      controller: _notesController,
                      maxLines: null,
                      expands: true,
                      obscureText: false,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: "Allergies, special requests, etc.\n\n",
                      ),
                      // onChanged: (String newEntry){
                      //   print("Password entered");
                      // },
                    ),
                  )
              ),
              SizedBox(height: 25,),
              SizedBox(
                  height: 45,
                  width: 350,
                  child: FilledButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        )
                    ),
                    child: Text("Submit", style:TextStyle(color:Colors.white, fontSize: 16)),
                    onPressed: (){
                      _requestFood();
                    },
                  )
              ),
              SizedBox(height: 20,),
              SizedBox(
                  height: 45,
                  width: 350,
                  child: FilledButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        )
                    ),
                    child: Text("View donations", style:TextStyle(color:Colors.white, fontSize: 16)),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const RequestFood2()));;
                    },
                  )
              ),
              Container(
                padding: EdgeInsets.only(top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home, size: 30),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const Home()));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.explore_outlined, size: 30),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const Home()));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined, size: 30),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const Home()));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 30),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const Home()));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outlined, size: 30),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const profile()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )

      ),
    );
  }
}