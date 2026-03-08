import 'package:communityplateproject2/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:communityplateproject2/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class registerpage extends StatefulWidget {
  const registerpage({super.key});

  @override
  State<registerpage> createState() => _registerpageState();
}

class _registerpageState extends State<registerpage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 50,),
                  Container(
                      height: 50,
                      child: Text(
                        'FullTray',
                        softWrap: true,
                        style: TextStyle(
                            fontFamily: 'Koulen',
                            //fontWeight: FontWeight.bold,
                            fontSize: 30,
                            letterSpacing: 3.0
                        ),
                        textAlign: TextAlign.center,
                      )
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 35),
                  SizedBox(
                      width: 350,
                      height: 45,
                      child: Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          obscureText: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            hintText: "email@domain.com",
                          ),
                          validator: (String? email) {
                            if(email == null || email.isEmpty) {
                              return 'Please enter your email.';
                            }
                            return null;
                          },
                        ),
                      )
                  ),
                  SizedBox(height:20),
                  SizedBox(
                      width: 350,
                      height: 45,
                      child: Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            hintText: "name",
                          ),
                          validator: (String? name) {
                            if(name == null || name.isEmpty) {
                              return 'Please enter your name/organization name.';
                            }
                            return null;
                          },
                        ),
                      )
                  ),
                  SizedBox(height:20),
                  SizedBox(
                    width: 350,
                    height: 45,
                    child: TextFormField(
                      controller: _addressController,
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: "address (street, city, state)",
                      ),
                      validator: (String? address) {
                        if (address == null || address.isEmpty) {
                          return 'Please enter your address.';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height:20),
                  SizedBox(
                      width: 350,
                      height: 45,
                      child: Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            hintText: "password",
                          ),
                          validator: (String? password) {
                            if(password == null || password.length < 8) {
                              return 'Please enter a password with at least 8 characters.';
                            }
                            return null;
                          },
                        ),
                      )
                  ),
                  SizedBox(height: 20,),
                  SizedBox(
                      width: 350,
                      height: 45,
                      child: Expanded(
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            hintText: "re-enter password",
                          ),
                          validator: (String? password) {
                            if(password != _passwordController.text) {
                              return 'Passwords do not match.';
                            }
                            return null;
                          },
                        ),
                      )
                  ),
                  SizedBox(height: 20),
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
                        child: Text("Register", style:TextStyle(color:Colors.white, fontSize: 16)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );

                                await cred.user?.updateDisplayName(_nameController.text.trim());

                                await cred.user?.reload();

                                final updatedUser = FirebaseAuth.instance.currentUser;
                                print("Display name set to: ${updatedUser?.displayName}");

                                final uid = cred.user!.uid;

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .set({
                                  "name": _nameController.text.trim(),
                                  "email": _emailController.text.trim(),
                                  "address": _addressController.text.trim(),
                                  "locationSet": true, // address provided
                                  "createdAt": FieldValue.serverTimestamp(),
                                });
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const loginpage()));
                              } catch (e) {
                                print("Error: $e");
                              }
                            }
                          }
                      )
                  )
                ]
            ),
          )
      ),
    );
  }
}
