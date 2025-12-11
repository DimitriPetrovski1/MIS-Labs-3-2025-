import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal_summary.dart';
import '../widgets/meal_grid.dart';

class CategoryMealsPage extends StatefulWidget {
  const CategoryMealsPage({super.key});

  @override
  State<CategoryMealsPage> createState() => _CategoryMealsPageState();
}

class _CategoryMealsPageState extends State<CategoryMealsPage> {
  final ApiService _api = ApiService();
  List<MealSummary> _meals = [];
  List<MealSummary> _filtered = [];
  bool _isLoading = true;
  bool _isSearchingApi = false;
  final TextEditingController _controller = TextEditingController();
  String _category = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final catArg = ModalRoute.of(context)!.settings.arguments;
    if (catArg is String) {
      _category = catArg;
      _loadMeals();
    }
  }

  Future<void> _loadMeals() async {
    final list = await _api.mealsByCategory(_category);
    setState(() {
      _meals = list;
      _filtered = list;
      _isLoading = false;
    });
  }

  void _filterLocal(String q) {
    setState(() {
      if (q.isEmpty) {
        _filtered = _meals;
      } else {
        _filtered = _meals.where((m) => m.strMeal.toLowerCase().contains(q.toLowerCase())).toList();
      }
    });
  }

  Future<void> _searchApi(String q) async {
    if (q.isEmpty) return;
    setState(() { _isSearchingApi = true; });
    final results = await _api.searchMeals(q);
    setState(() {
      _isSearchingApi = false;
      _filtered = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Категорија: $_category'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Пребарај јадења (локално или притисни „Search in API“)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: TextButton(
                  onPressed: _isSearchingApi ? null : () => _searchApi(_controller.text.trim()),
                  child: _isSearchingApi ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Search in API'),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filterLocal,
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Нема јадења', style: TextStyle(color: Colors.grey)),
              ],
            ))
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: MealGrid(meals: _filtered),
            ),
          ),
        ],
      ),
    );
  }
}// TODO Implement this library.