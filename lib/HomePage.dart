import 'package:communityplateproject2/DonateFood.dart';
import 'package:communityplateproject2/DonateFood2.dart';
import 'package:communityplateproject2/Firebase/ai_search_service.dart';
import 'package:communityplateproject2/ProfilePage.dart';
import 'package:communityplateproject2/RequestFood.dart';
import 'package:communityplateproject2/RequestFood2.dart';
import 'package:communityplateproject2/Notifications.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:communityplateproject2/Firebase/firebase_service.dart';
import 'package:communityplateproject2/Firebase/food_item.dart';
import 'package:communityplateproject2/Firebase/food_request.dart';
import 'package:communityplateproject2/SearchItem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final AISearchService _aiSearch = AISearchService();
  final FirebaseService _firebaseService = FirebaseService();
  List<SearchItem> _results = [];
  bool _loading = false;
  double? _userLat;
  double? _userLng;

  Future<void> _loadUserLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null) return;

    final GeoPoint? location = data['location'];
    if (location != null) {
      setState(() {
        _userLat = location.latitude;
        _userLng = location.longitude;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  //initialize food item
  FoodItem f = FoodItem(id: "123", name: "name", type: "type", quantity: "quantity", expirationDate: DateTime.now(), address: "address", donor: "donor", createdAt: DateTime.now());

  List<Widget> imageList = [
    ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.network("https://images.ctfassets.net/rric2f17v78a/7g4ABXMbw7Yxldu9rWucN7/0781ca0e17f180a6dad586f0d4eb0a7f/BakeryHero_2022-12-12-210752_zfsl.jpg", width: 375, height: 125, fit: BoxFit.cover),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.network("https://www.allrecipes.com/thmb/0xH8n2D4cC97t7mcC7eT2SDZ0aE=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/6776_Pizza-Dough_ddmfs_2x1_1725-fdaa76496da045b3bdaadcec6d4c5398.jpg", width: 375, height: 125, fit: BoxFit.cover),
    ),
    ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.network("https://popmenucloud.com/rilwatzf/c2b948b5-8105-4b14-86f1-a56f56b1a1ab.jpg", width: 375, height: 150, fit: BoxFit.cover)
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30,),
            SizedBox(
                width: 375,
                height: 45,
                child: TextField(
                  controller: _searchController,
                  obscureText: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: "Search (AI-powered results)",
                    hintText: "Fruits near me, etc.",
                    hintStyle: TextStyle(
                      color: Colors.grey
                    ),
                  ),
                  onSubmitted: (value) async {
                    if (_userLat == null || _userLng == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Set your location in your profile first")),
                      );
                      return;
                    }

                    setState(() => _loading = true);

                    final allItems = await _firebaseService.fetchAllSearchItems();
                    final results = await _aiSearch.aiSearchFood(
                      value,
                      allItems,
                      _userLat!,
                      _userLng!,
                    );

                    setState(() {
                      _results = results;
                      _loading = false;
                    });
                  },
                ),
            ),
            if (_loading)
              const CircularProgressIndicator(),

            if (!_loading && _results.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView(
                  children: _results.map((item) {
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        "${item.type} • ${item.quantity} • "
                            "${item.isDonation ? 'Donated' : 'Requested'}",
                      ),
                    );
                  }).toList(),
                ),
              ),
            /*
            Container(
              margin: EdgeInsets.fromLTRB(12.5, 7, 12.5, 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 12)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          )
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.favorite_outline, color: Colors.grey.shade700,),
                          Text(" Favorites", style:TextStyle(color:Colors.black, fontSize: 14)),
                        ],
                      ),
                      onPressed: (){},
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: OutlinedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 12)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          )
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.history_outlined, color: Colors.grey.shade700,),
                          Text(" History", style:TextStyle(color:Colors.black, fontSize: 14)),
                        ],
                      ),
                      onPressed: (){},
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: OutlinedButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 12)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          )
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.person_2_outlined, color: Colors.grey.shade700,),
                          Text(" Following", style:TextStyle(color:Colors.black, fontSize: 14)),
                        ],
                      ),
                      onPressed: (){},
                    )
                  ),


                ],
              ),
            ),

             */
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '    Trending items',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      //letterSpacing: 1.0
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    height: 175,
                    width: 375,
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 20),
                    //padding: EdgeInsets.fromLTRB(10, 50, 10, 0),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        //height: 125,
                        //aspectRatio: ,
                        viewportFraction: 1,
                        enlargeCenterPage: false,
                      ),
                      items:imageList.map((item)=>item).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '    Request food',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    //letterSpacing: 1.0
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=>requestFood(foodItem: f,)));
                      },
                      child: CircleAvatar(radius: 40, backgroundImage: NetworkImage("https://res.cloudinary.com/hz3gmuqw6/image/upload/c_fill,h_450,q_auto,w_710/f_auto/wip--21-healthiest-fruits-to-eat-in-2024-php3RGRfc")),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      "Fruits",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=> requestFood(foodItem: f)));
                      },
                      child: CircleAvatar(radius: 40, backgroundImage: NetworkImage("https://www.eatright.org/-/media/images/eatright-landing-pages/grainslp_804x482.jpg?h=482&w=804&rev=d44c22d03d0b452a9e266ff827d25534&hash=C170BE6A1B67C3A04A27A2F1A906E568")),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      "Grains",
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=> requestFood(foodItem: f)));
                      },
                      child: CircleAvatar(radius: 40, backgroundImage: NetworkImage("https://cdn.britannica.com/17/196817-159-9E487F15/vegetables.jpg")),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      "Vegetables",
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=> requestFood(foodItem: f)));
                      },
                      child: CircleAvatar(radius: 40, backgroundImage: NetworkImage("https://media.theeverymom.com/wp-content/uploads/2023/08/22105814/healthy-after-school_snacks-banana-sushi-rolls-the-everymom11.jpg")),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      "Snacks",
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=> requestFood(foodItem: f)));
                      },
                      child: CircleAvatar(radius: 40, backgroundImage: NetworkImage("https://imageio.forbes.com/specials-images/imageserve/601063988/0x0.jpg?format=jpg&height=900&width=1600&fit=bounds")),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      "Meat",
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=> requestFood(foodItem: f,)));
                      },
                      child: CircleAvatar(radius: 40, backgroundImage: NetworkImage("https://www.shutterstock.com/image-photo/assortment-baked-goods-displayed-on-600nw-2575371219.jpg")),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      "Other",
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '    Donate food',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    //letterSpacing: 1.0
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(width: 12.5,),
                SizedBox(
                    height: 45,
                    width: 180,
                    child: FilledButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 10)),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          )
                      ),
                      child: Text("Donate what you have", style:TextStyle(color:Colors.white, fontSize: 14)),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=>DonateFood2(foodItem: f,)));
                        tooltip: 'Increment';
                      },
                    )
                ),
                SizedBox(width: 15,),
                SizedBox(
                    height: 45,
                    width: 180,
                    child: FilledButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 10)),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          )
                      ),
                      child: Text("See requested food", style:TextStyle(color:Colors.white, fontSize: 14)),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const donateFood()));
                        tooltip: 'Increment';
                      },
                    )
                ),
              ],
            ),
            SizedBox(height: 40),
            Container(
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
                      Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const donateFood()));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, size: 30),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const RequestFood2()));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 30),
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder : (context)=>const Notifications()));
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
    );
  }
}
