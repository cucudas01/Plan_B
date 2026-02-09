import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 환경 변수 로드용
import 'screens/recommendation_screen.dart'; // 메인 추천 화면 (새로 만든 구조)
import 'theme.dart'; // 방금 만든 테마 파일

void main() async {
  // 비동기 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // .env 파일을 읽어와 API 키 등을 준비합니다.
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Could not load .env file: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan B',
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      theme: AppTheme.theme, // 위에서 정의한 AppTheme 적용
      // 앱의 첫 화면을 AI 추천 화면으로 설정합니다.
      home: const RecommendationScreen(),
    );
  }
}