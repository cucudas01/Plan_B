import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/restaurant.dart';

class GeminiService {
  static Future<List<Restaurant>> fetchRecommendations({
    required double lat, required double lng, required String apiKey,
  }) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    String cityName = placemarks.first.locality ?? '이 도시';

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

    final prompt = '현재 $cityName($lat,$lng) 근처 현지인 맛집 10곳 추천. JSON 배열로만 응답. 필드: region, category, name, rating, reviews, price, opentime, tips, waiting, lat, lng';

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"contents": [{"parts": [{"text": prompt}]}]}));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      String rawText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      String jsonText = rawText.substring(rawText.indexOf('['), rawText.lastIndexOf(']') + 1);
      List<dynamic> parsedJson = json.decode(jsonText);

      return parsedJson.map((item) => Restaurant(
        name: item['name'] ?? '정보 없음', category: item['category'] ?? '식당',
        region: item['region'] ?? cityName, rating: (item['rating'] ?? 0.0).toDouble(),
        reviews: item['reviews'] ?? 0, price: item['price'] ?? 0, address: item['region'] ?? '',
        lat: (item['lat'] ?? 0.0).toDouble(), lng: (item['lng'] ?? 0.0).toDouble(),
        isOpen: true, opentime: item['opentime'] ?? '', tips: item['tips'] ?? '',
        waiting: item['waiting'] ?? '', link: '',
        image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=400',
        distance: Geolocator.distanceBetween(lat, lng, (item['lat'] ?? 0.0).toDouble(), (item['lng'] ?? 0.0).toDouble()),
      )).toList();
    }
    throw Exception("AI 연결 실패");
  }
}