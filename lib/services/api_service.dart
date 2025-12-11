import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../models/meal_summary.dart';
import '../models/meal_detail.dart';

class ApiService {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$_base/categories.php');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = (data['categories'] as List).map((e) => Category.fromJson(e)).toList();
      return list;
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<MealSummary>> mealsByCategory(String category) async {
    final url = Uri.parse('$_base/filter.php?c=$category');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final list = (data['meals'] as List).map((e) => MealSummary.fromJson(e)).toList();
      return list;
    } else {
      throw Exception('Failed to load meals for $category');
    }
  }

  Future<List<MealSummary>> searchMeals(String query) async {
    final url = Uri.parse('$_base/search.php?s=$query');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['meals'] == null) return [];
      final list = (data['meals'] as List).map((e) {
        // search endpoint returns full meal objects; map to summary
        return MealSummary.fromJson({
          'idMeal': e['idMeal'],
          'strMeal': e['strMeal'],
          'strMealThumb': e['strMealThumb'],
        });
      }).toList();
      return list;
    } else {
      throw Exception('Failed to search meals');
    }
  }

  Future<MealDetail?> lookupMeal(String id) async {
    final url = Uri.parse('$_base/lookup.php?i=$id');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['meals'] == null) return null;
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to lookup meal $id');
    }
  }

  Future<MealDetail?> randomMeal() async {
    final url = Uri.parse('$_base/random.php');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['meals'] == null) return null;
      return MealDetail.fromJson(data['meals'][0]);
    } else {
      throw Exception('Failed to get random meal');
    }
  }
}