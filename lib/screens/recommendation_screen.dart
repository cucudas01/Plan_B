import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수 사용
import 'package:geolocator/geolocator.dart'; // 위치 정보 획득
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
    // 앱 시작 시 맛집 데이터 로딩 시작
    _restaurantFuture = _loadRestaurants();
  }

  /// 위치 권한을 확인하고 맛집 데이터를 불러오는 핵심 로직입니다.
  Future<List<Restaurant>> _loadRestaurants() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 기기의 위치 서비스(GPS)가 켜져 있는지 확인합니다.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다. 설정에서 켜주세요.');
    }

    // 2. 앱의 위치 권한 상태를 확인합니다.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 권한이 없다면 사용자에게 요청합니다.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다. 추천을 위해 권한이 필요합니다.');
      }
    }

    // 3. 사용자가 권한을 영구적으로 거부한 경우 처리입니다.
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.');
    }

    // 4. 모든 권한이 확인되면 현재 위치(위도, 경도)를 가져옵니다.
    Position position = await Geolocator.getCurrentPosition();

    // 5. Gemini AI 서비스를 호출하여 맛집 목록을 받아옵니다.
    return GeminiService.fetchRecommendations(
      lat: position.latitude,
      lng: position.longitude,
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '', // 보안을 위해 .env에서 키를 읽어옴
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 추천 맛집'),
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _restaurantFuture,
        builder: (context, snapshot) {
          // 데이터 로딩 중 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // 에러 발생 시 표시 (권한 거부 등)
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          // 데이터 로드 완료 후 리스트 표시
          else if (snapshot.hasData) {
            final items = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) => RestaurantCard(restaurant: items[index]),
            );
          }

          return const Center(child: Text('추천 데이터가 없습니다.'));
        },
      ),
    );
  }
}