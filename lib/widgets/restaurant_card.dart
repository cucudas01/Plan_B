import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../theme.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(restaurant.image, height: 180, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(restaurant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen ? AppTheme.primaryColor : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(restaurant.isOpen ? '영업중' : '영업종료', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${restaurant.category} · ${restaurant.region}'),
                const Divider(height: 24),
                Text('💡 AI Tip', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                Text(restaurant.tips, style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}