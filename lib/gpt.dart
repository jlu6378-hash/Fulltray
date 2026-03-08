import 'dart:convert';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:flutter/material.dart';
import 'package:communityplateproject2/SearchItem.dart';

class AiSearchService {
  late final OpenAI _openAI;

  AiSearchService() {
    _openAI = OpenAI.instance.build(
      token: dotenv.env['OPENAI_API_KEY'],
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<List<String>> filterItemsWithAI({
    required String query,
    required List<SearchItem> items,
  }) async {
    final compactItems = items.map((e) => e.toJson()).toList();

    final prompt = """
    You are a search engine for a food donation app.
    
    User search:
    "$query"
    
    Items:
    ${jsonEncode(compactItems)}
    
    Return only valid JSON in this format:
    {
      "matched_ids" : ["id1", "id2", "..."]
    }
    
    Match by meaning and not exact words, include both donations and requests as long as they're relevant, and don't explain anything.
    """;

    final request = ChatCompleteText(
      messages: [{"role": "user", "content": prompt}],
      model: GptTurboChatModel(),
      maxToken: 1500,
    );

    final response = await _openAI.onChatCompletion(request: request);

    final decoded = jsonDecode(
        response!.choices.first.message!.content.trim()
    );

    return List<String>.from(decoded["matched_ids"]);
  }
}

class FoodCategorizer {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final OpenAI _openAI;

  FoodCategorizer() {
    _openAI = OpenAI.instance.build(
      token: dotenv.env['OPENAI_API_KEY'],
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  Future<Map<String, String>> categorizeFoodRequests() async {
    final snapshot = await _db.collection("Requested Food").get();
    if (snapshot.docs.isEmpty) return {};

    List<Map<String, dynamic>> foodRequests = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "id" : doc.id,
        "name" : data['name'] ?? '',
        "quantity" : data['quantity'] ?? '',
        "notes" : data["notes"] ?? '',
      };
    }).toList();

    final userPrompt = """
    You are a food categorization AI. Categorize each of item into one of the following:
    ["Fruits", "Grains", "Vegetables", "Snacks", "Meat", "Other"]
    
    Here is the list of food requests:
    ${jsonEncode(foodRequests)}
    
    Return only valid JSON in the following format:
    [
      {
        "id" : "<document id>",
        "category" : "<category>"
      }
    ]
    """;

    final request = ChatCompleteText(
        model: GptTurboChatModel(),
        maxToken: 2000,
        messages: [
          {"role" : "user", "content" : userPrompt}
        ]
    );

    final response = await _openAI.onChatCompletion(request: request);
    final content = response?.choices.first.message?.content.trim() ?? "";
    final decoded = jsonDecode(content);

    Map<String, String> result = {};
    for(var entry in decoded) {
      result[entry["id"]] = entry["category"];
    }

    return result;
  }

}