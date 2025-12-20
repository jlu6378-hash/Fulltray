import 'package:communityplateproject2/LoginPage.dart';
import 'package:flutter/material.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  @override
  void initState() {
    super.initState();
    init();
  }
  Future<void>init() async{
    await Future.delayed(const Duration(seconds: 2)).then((value) {
      Navigator.pop(context);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const loginpage()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 62, 106, 85),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("COMMUNITY PLATE PROJECT",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Koulen',
                      color: Colors.white,
                      fontSize: 30,
                      letterSpacing: 3.0
                  ),
                ),
                SizedBox(height: 30,),
                Image.asset('assets/cpp_logo_white.png', height: 350),
              ],
            )
        )
    );
  }
}
