import 'package:communityplateproject2/AI.dart';
import 'package:communityplateproject2/HomePage.dart';
import 'package:communityplateproject2/RegisterPage.dart';
import 'package:flutter/material.dart';
import 'package:communityplateproject2/Firebase/db_testA.dart';
import 'package:communityplateproject2/Categorizertest.dart';
import 'package:firebase_auth/firebase_auth.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _loginError = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Container(
                  height: 50,
                  child: Text(
                    'FULLTRAY',
                    softWrap: true,
                    style: TextStyle(
                      fontFamily: 'Koulen',
                      //fontWeight: FontWeight.bold,
                      fontSize: 40,
                      letterSpacing: 4.0
                    ),
                    textAlign: TextAlign.center,
                  )
                ),
                Image.asset('assets/cpp_logo_green.png',
                    height: 200),
                SizedBox(height: 20),
                SizedBox(
                  width: 350,
                  height: 45,
                  child: Expanded(
                    child: TextField(
                      controller: _emailController,
                      obscureText: false,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: "email@domain.com",
                      ),
                      // onChanged: (String newEntry){
                      //   print("Password entered");
                      // },
                    ),
                  )
                ),
                SizedBox(height:20),
                SizedBox(
                  width: 350,
                  height: 45,
                  child: Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: "password",
                        suffixIcon: GestureDetector(
                          onTap: (){
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility
                          ),
                        )
                      ),
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
                      child: Text("Log in", style:TextStyle(color:Colors.white, fontSize: 16)),
                      onPressed: (){
                        signIn(_emailController.text, _passwordController.text).then(
                          (bool success) {
                            if (success) {
                              print('Signed in');
                              Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const Home()));
                            }
                            setState(() {
                              _loginError = !success;
                            });
                          }
                        );
                      },
                    )
                ),
                SizedBox(height: 30),
                Text("────────── or ──────────", style:TextStyle(color: Colors.grey, fontSize: 16)),
                SizedBox(height: 30),
                SizedBox(
                    height: 45,
                    width: 350,
                    child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/google.png', height: 20),
                          Text("  Continue with Google", style:TextStyle(color:Colors.black, fontSize: 16)),
                        ],
                      ),
                      onPressed: (){},
                    )
                ),
                SizedBox(height: 10),
                SizedBox(
                    height: 45,
                    width: 350,
                    child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/apple.png', height: 20),
                          Text("  Continue with Apple", style:TextStyle(color:Colors.black, fontSize: 16)),
                        ],
                      ),
                      onPressed: (){},
                    )
                ),
                SizedBox(height: 40),
                TextButton(
                  child: Text("Click here to create an account", style:TextStyle(color:Colors.black, fontSize: 15)),
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const registerpage()));
                    tooltip: 'Increment';
                  },
                ),
              ]
          )
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const CategorizedFoodPage()));
          tooltip: 'Increment';
        },
        child: const Icon(Icons.add),
      ),

    );
  }
}
