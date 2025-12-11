import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../models/meal_summary.dart';
import '../widgets/meal_grid.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FavoritesService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Омилени рецепти'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.favoritesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text('Немате омилени рецепти'));
          }

          final meals = data.map((m) {
            return MealSummary(
              idMeal: m['id'] ?? m['idMeal'] ?? '',
              strMeal: m['name'] ?? '',
              strMealThumb: m['thumb'] ?? '',
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: MealGrid(meals: meals),
          );
        },
      ),
    );
  }
}