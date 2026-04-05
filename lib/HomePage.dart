import 'package:communityplateproject2/DonateFood.dart';
import 'package:communityplateproject2/DonateConfirmation.dart';
import 'package:communityplateproject2/DonateFood2.dart';
import 'package:communityplateproject2/Firebase/ai_search_service.dart';
import 'package:communityplateproject2/ProfilePage.dart';
import 'package:communityplateproject2/RequestConfirmation.dart';
import 'package:communityplateproject2/RequestFood.dart';
import 'package:communityplateproject2/RequestFood2.dart';
import 'package:communityplateproject2/Notifications.dart';
import 'package:communityplateproject2/SearchResultsPage.dart';
import 'package:communityplateproject2/category_images.dart';
import 'package:flutter/material.dart';
import 'package:communityplateproject2/Firebase/firebase_service.dart';
import 'package:communityplateproject2/Firebase/food_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _TrendingListing {
  final String id;
  final String name;
  final String type;
  final String quantity;
  final bool isDonation;
  final String ownerUid;
  final DateTime createdAt;

  const _TrendingListing({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.isDonation,
    required this.ownerUid,
    required this.createdAt,
  });
}

class _HomeState extends State<Home> {
  final TextEditingController _searchController = TextEditingController();
  final AISearchService _aiSearch = AISearchService();
  final FirebaseService _firebaseService = FirebaseService();
  bool _loading = false;
  double? _userLat;
  double? _userLng;
  late Future<List<_TrendingListing>> _trendingFuture;

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

  Future<List<_TrendingListing>> _fetchTrendingListings() async {
    final db = FirebaseFirestore.instance;

    final donationsFuture = db
        .collection('Donated Food')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .get();
    final requestsFuture = db
        .collection('Requested Food')
        .orderBy('createdAt', descending: true)
        .limit(3)
        .get();

    final results = await Future.wait([donationsFuture, requestsFuture]);
    final donations = results[0];
    final requests = results[1];

    final merged = <_TrendingListing>[];

    for (final doc in donations.docs) {
      final data = doc.data();
      final ts = data['createdAt'] as Timestamp?;
      merged.add(
        _TrendingListing(
          id: doc.id,
          name: (data['name'] ?? 'Unnamed').toString(),
          type: (data['type'] ?? 'Unknown').toString(),
          quantity: (data['quantity'] ?? 'N/A').toString(),
          isDonation: true,
          ownerUid: (data['requester'] ?? '').toString(),
          createdAt: ts?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }

    for (final doc in requests.docs) {
      final data = doc.data();
      final ts = data['createdAt'] as Timestamp?;
      merged.add(
        _TrendingListing(
          id: doc.id,
          name: (data['name'] ?? 'Unnamed').toString(),
          type: (data['type'] ?? 'Unknown').toString(),
          quantity: (data['quantity'] ?? 'N/A').toString(),
          isDonation: false,
          ownerUid: (data['requester'] ?? '').toString(),
          createdAt: ts?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }

    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged.take(3).toList();
  }

  void _openTrendingAction(_TrendingListing item) {
    if (item.ownerUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load listing owner info.')),
      );
      return;
    }

    if (item.isDonation) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RequestConfirmation(
            donationId: item.id,
            donatorUid: item.ownerUid,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DonateConfirmation(
          requestId: item.id,
          requesterUid: item.ownerUid,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _trendingFuture = _fetchTrendingListings();
  }

  //initialize food item
  FoodItem f = FoodItem(id: "123", name: "name", type: "type", quantity: "quantity", expirationDate: DateTime.now(), address: "address", donor: "donor", createdAt: DateTime.now());

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

                    setState(() => _loading = false);

                    if (!mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchResultsPage(
                          query: value,
                          results: results,
                          userLat: _userLat!,
                          userLng: _userLng!,
                        ),
                      ),
                    );
                  },
                ),
            ),
            if (_loading)
              const CircularProgressIndicator(),
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
              child: FutureBuilder<List<_TrendingListing>>(
                future: _trendingFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No recent listings yet.'),
                    );
                  }

                  final screenW = MediaQuery.sizeOf(context).width;
                  final cardWidth = screenW - 25;

                  return SizedBox(
                    height: 260,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return SizedBox(
                          width: cardWidth,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _openTrendingAction(item),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    categoryImageUrl(item.type),
                                    fit: BoxFit.cover,
                                  ),
                                  Container(color: Colors.black.withOpacity(0.45)),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Chip(
                                              label: Text(
                                                item.isDonation ? 'Donation' : 'Request',
                                                style: const TextStyle(fontSize: 11),
                                              ),
                                              visualDensity: VisualDensity.compact,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${item.type} • ${item.quantity}',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        const Spacer(),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: FilledButton(
                                            onPressed: () => _openTrendingAction(item),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                            ),
                                            child: Text(item.isDonation ? 'Request' : 'Donate'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
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
