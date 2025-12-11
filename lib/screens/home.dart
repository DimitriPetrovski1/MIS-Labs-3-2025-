import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../widgets/category_card.dart';
import '../screens/details.dart'; // for route type hints not strictly required

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiService _api = ApiService();
  late List<Category> _categories;
  List<Category> _filtered = [];
  bool _isLoading = true;
  String _query = '';
  final TextEditingController _controller = TextEditingController();
  bool _isRandomLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _api.fetchCategories();
    setState(() {
      _categories = list;
      _filtered = list;
      _isLoading = false;
    });
  }

  void _filter(String q) {
    setState(() {
      _query = q;
      if (q.isEmpty) {
        _filtered = _categories;
      } else {
        _filtered = _categories.where((c) => c.strCategory.toLowerCase().contains(q.toLowerCase())).toList();
      }
    });
  }

  Future<void> _openRandom() async {
    setState(() { _isRandomLoading = true; });
    final meal = await _api.randomMeal();
    setState(() { _isRandomLoading = false; });
    if (meal != null) {
      Navigator.pushNamed(context, '/details', arguments: meal);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не може да се земе рандом рецепт')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          IconButton(
            tooltip: 'Random meal',
            onPressed: _isRandomLoading ? null : _openRandom,
            icon: _isRandomLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.casino),
          ),
        ],
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
                hintText: 'Пребарај категории...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filter,
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Нема категории', style: TextStyle(color: Colors.grey)),
              ],
            ))
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cat = _filtered[index];
                return CategoryCard(
                  category: cat,
                  onTap: () {
                    Navigator.pushNamed(context, '/categoryMeals', arguments: cat.strCategory);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}// TODO Implement this library.