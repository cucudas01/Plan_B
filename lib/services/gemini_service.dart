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

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$apiKey');

    final prompt = '''
      현재 도시: $cityName (위도: $lat, 경도: $lng)
      이 근처의 현지인 맛집 10~15곳을 추천해줘.
      JSON 배열 형식으로만 응답하고 마크다운은 금지야.
      필드: region, category, name, name_local, rating, reviews, price, link, image, opentime, tips, waiting, lat, lng
    ''';

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"contents": [{"parts": [{"text": prompt}]}]}));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      String rawText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      String jsonText = rawText.replaceAll(RegExp(r'```json|```'), '').trim();
      List<dynamic> parsedJson = json.decode(jsonText);

      return parsedJson.map((item) {
        double rLat = double.tryParse(item['lat'].toString()) ?? 0.0;
        double rLng = double.tryParse(item['lng'].toString()) ?? 0.0;
        return Restaurant(
          region: item['region'] ?? '',
          category: item['category'] ?? '음식점',
          name: item['name'] ?? '정보 없음',
          nameLocal: item['name_local'],
          lat: rLat, lng: rLng,
          opentime: item['opentime'] ?? '정보없음',
          tips: item['tips'] ?? '',
          waiting: item['waiting'] ?? '정보없음',
          rating: double.tryParse(item['rating'].toString()) ?? 0.0,
          reviews: int.tryParse(item['reviews'].toString()) ?? 0,
          price: int.tryParse(item['price'].toString()) ?? 0,
          link: item['link'] ?? '',
          image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=400', // 샘플 이미지
          distance: Geolocator.distanceBetween(lat, lng, rLat, rLng),
        );
      }).toList()..sort((a, b) => a.distance!.compareTo(b.distance!));
    } else {
      throw Exception("API 연결 실패");
    }
  }
}