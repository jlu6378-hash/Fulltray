import 'package:flutter/material.dart';
import 'package:communityplateproject2/gpt.dart';

class CategorizedFoodPage extends StatefulWidget {
  const CategorizedFoodPage({super.key});

  @override
  State<CategorizedFoodPage> createState() => _CategorizedFoodPageState();
}

class _CategorizedFoodPageState extends State<CategorizedFoodPage> {
  final FoodCategorizer _categorizer = FoodCategorizer();
  bool _loading = true;
  Map<String, String> _categories = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await _categorizer.categorizeFoodRequests();
    setState(() {
      _categories = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Categorized Food Requests")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(20),
        children: _categories.entries.map((entry) {
          return ListTile(
            title: Text("Request ID: ${entry.key}"),
            subtitle: Text("Category: ${entry.value}"),
          );
        }).toList(),
      ),
    );
  }
}
