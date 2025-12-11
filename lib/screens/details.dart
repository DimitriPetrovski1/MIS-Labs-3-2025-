import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import '../models/meal_summary.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart'; // add near other imports
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final ApiService _api = ApiService();
  MealDetail? _meal;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is MealDetail) {
      _meal = arg;
      _isLoading = false;
    } else if (arg is MealSummary) {
      _loadDetail(arg.idMeal);
    } else if (arg is String) {
      _loadDetail(arg);
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadDetail(String id) async {
    final detail = await _api.lookupMeal(id);
    setState(() {
      _meal = detail;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_meal?.strMeal ?? 'Детали'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_meal != null)
            StreamBuilder<bool>(
              stream: FavoritesService().isFavorite(_meal!.idMeal),
              builder: (context, snapshot) {
                final isFav = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                  color: isFav ? Colors.red : null,
                  onPressed: () {
                    FavoritesService().toggleFavorite(_meal!.idMeal, {
                      'id': _meal!.idMeal,
                      'name': _meal!.strMeal,
                      'thumb': _meal!.strMealThumb,
                      'addedAt': FieldValue.serverTimestamp(),
                    });
                  },
                );
              },
            ),
        ],
      ),

      // ---------- ADD THIS BODY ----------
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _meal == null
          ? const Center(child: Text("Meal not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(_meal!.strMealThumb),
            ),
            const SizedBox(height: 16),

            Text(
              _meal!.strMeal,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Ingredients",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._meal!.ingredients.entries.map((e) => Text("• ${e.key}: ${e.value}")),

            const SizedBox(height: 24),

            const Text(
              "Instructions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_meal!.strInstructions),

            const SizedBox(height: 24),

            if (_meal!.strYoutube != null)
              ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(_meal!.strYoutube!);
                  if (await canLaunchUrl(url)) {
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text("Watch on YouTube"),
              ),
          ],
        ),
      ),
    );
  }
}