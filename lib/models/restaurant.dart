class Restaurant {
  final String region, category, name, opentime, tips, waiting, image, link;
  final String? nameLocal;
  final double? lat, lng, distance;
  final double rating;
  final int reviews, price;

  Restaurant({
    required this.region, required this.category, required this.name, this.nameLocal,
    required this.lat, required this.lng, required this.opentime, required this.tips,
    required this.waiting, required this.rating, required this.image, this.distance,
    required this.reviews, required this.price, required this.link
  });

  // 영업 상태 확인 로직
  bool get isOpen {
    if (opentime.isEmpty || opentime == '정보없음' || opentime.contains("24시간") || opentime == '영업중') return true;
    if (opentime == '영업종료') return false;
    try {
      final now = DateTime.now();
      final currentTimeInMinutes = now.hour * 60 + now.minute;
      for (String part in opentime.split(',')) {
        final times = part.trim().split('-');
        if (times.length != 2) continue;
        final start = times[0].trim().split(':');
        final end = times[1].trim().split(':');
        final startMinutes = int.parse(start[0]) * 60 + int.parse(start[1]);
        final endMinutes = int.parse(end[0]) * 60 + int.parse(end[1]);
        if (startMinutes <= endMinutes) {
          if (currentTimeInMinutes >= startMinutes && currentTimeInMinutes <= endMinutes) return true;
        } else {
          if (currentTimeInMinutes >= startMinutes || currentTimeInMinutes <= endMinutes) return true;
        }
      }
      return false;
    } catch (e) { return true; }
  }
}