import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:communityplateproject2/Firebase/food_item.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:communityplateproject2/SearchItem.dart';
import 'package:communityplateproject2/distance.dart';

class AISearchService {
  late final OpenAI _openAI;

  AISearchService() {
    _openAI = OpenAI.instance.build(
      token: dotenv.env['OPENAI_API_KEY'],
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<List<SearchItem>> aiSearchFood(
      String query,
      List<SearchItem> allItems,
      double userLat,
      double userLng,
      ) async {

    final nearbyItems = filterByDistance(
      items: allItems,
      userLat: userLat,
      userLng: userLng,
      maxMiles: 10, // configurable
    );

    if (nearbyItems.isEmpty) return [];

    final foods = nearbyItems.map((item) {
      return {
        "id": item.id,
        "name": item.name,
        "type": item.type,
        "quantity": item.quantity,
        "notes": item.notes,
        "isDonation": item.isDonation,
      };
    }).toList();

    final prompt = """
User search: "$query"
All items are within 10 miles of the user.

Food items:
${jsonEncode(foods)}

Return ONLY valid JSON.
Respond with a list of IDs that best match the search.
""";

    final request = ChatCompleteText(
      messages: [
        {"role": "user", "content": prompt}
      ],
      model: GptTurboChatModel(),
      maxToken: 500,
    );

    final response = await _openAI.onChatCompletion(request: request);
    final content = response!.choices.first.message!.content.trim();

    final List<dynamic> matchingIds = jsonDecode(content);

    return nearbyItems
        .where((item) => matchingIds.contains(item.id))
        .toList();
  }
}