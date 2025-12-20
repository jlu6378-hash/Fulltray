import 'dart:convert';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:openai_dart/openai_dart.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({
    Key? key,
    required this.food,
    required this.expiration,
    required this.quantity,
    required this.location
  }) : super(key: key);

  final List<String> food;
  final String expiration;
  final String quantity;
  final String location;

  @override
  State<TipsPage> createState() {
    return _TipsPageState();
  }
}

class _TipsPageState extends State<TipsPage> {
  late final OpenAI _openAI;
  bool _isLoading = true;
  Map _tips = {};

  @override
  void initState() {
    _openAI = OpenAI.instance.build(
      token: dotenv.env['OPENAI_API_KEY'],
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _handleInitialMessage();
    super.initState();
  }

  Future<void> _handleInitialMessage() async {
    String userPrompt = "Could you give me the best pantry (only one) I can donate my food close to where I live"
        "${widget.food} is the food type I'm donating"
        "${widget.expiration} is when it's expiring"
        "${widget.quantity} is how much food I'm donating"
        "${widget.location} is where I'm located"
        """Respond ONLY with valid JSON. Output a JSON list like:
          [
            {
              "pantry name": "",
              "address": "",
              "opening time": "",
              "closing time": ""
            }
          ]
          Do NOT add any explanation or text outside the JSON.""";

    final request = ChatCompleteText(
      messages: [
        Map.of({"role" : "user", "content" : userPrompt})
      ],
      model: GptTurboChatModel(),
      maxToken: 2000,
    );

    ChatCTResponse? response = await _openAI.onChatCompletion(request : request);

    setState(() {
      String result = response!.choices.first.message!.content.trim();

      try {
        final decoded = json.decode(result);

        if (decoded is List) {
          // Take the first pantry
          _tips = decoded.first;
        } else if (decoded is Map) {
          // If the model returns a single pantry as a map
          _tips = decoded;
        } else {
          print("Unexpected JSON format");
        }

        _isLoading = false;
      } catch (e) {
        print("Error parsing JSON: $e");
        _isLoading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("ChatGPT Example",)), body: Padding(
        padding: const EdgeInsets.all(15),
        child: !_isLoading
            ? ListView(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Text(
              _tips.toString(),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        )
            : Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: const CircularProgressIndicator(),
          ),
        )
    ));
  }
}
