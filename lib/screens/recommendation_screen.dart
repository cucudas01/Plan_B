import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';
import '../services/gemini_service.dart';
import '../widgets/restaurant_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  late Future<List<Restaurant>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<Restaurant>> _fetch() async {
    Position pos = await Geolocator.getCurrentPosition();
    return GeminiService.fetchRecommendations(
      lat: pos.latitude, lng: pos.longitude, apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    );
  }

  Future<void> _save(Restaurant res) async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> list = jsonDecode(prefs.getString('saved_restaurants') ?? '[]');
    list.add(res.toJson());
    await prefs.setString('saved_restaurants', jsonEncode(list));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${res.name} 저장됨!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 추천 결과')),
      body: FutureBuilder<List<Restaurant>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final res = snapshot.data![i];
              return Stack(
                children: [
                  RestaurantCard(restaurant: res),
                  Positioned(right: 10, top: 10, child: IconButton(
                    icon: const Icon(Icons.bookmark_add, color: Colors.blue, size: 32),
                    onPressed: () => _save(res),
                  )),
                ],
              );
            },
          );
        },
      ),
    );
  }
}