import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import '../services/gemini_service.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  late Future<List<Restaurant>> _restaurantFuture;

  @override
  void initState() {
    super.initState();
    _restaurantFuture = _loadRestaurants();
  }

  Future<List<Restaurant>> _loadRestaurants() async {
    // 위치 권한 획득 및 호출 로직
    Position position = await Geolocator.getCurrentPosition();
    return GeminiService.fetchRecommendations(
      lat: position.latitude,
      lng: position.longitude,
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 추천 맛집')),
      body: FutureBuilder<List<Restaurant>>(
        future: _restaurantFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다.'));
          }
          final items = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) => RestaurantCard(restaurant: items[index]),
          );
        },
      ),
    );
  }
}