import 'package:flutter/material.dart';
import 'package:mis_labs_2_2025/screens/category_meals.dart';
import 'package:mis_labs_2_2025/screens/details.dart';
import 'package:mis_labs_2_2025/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mis_labs_2_2025/screens/favorites.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meals App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const MyHomePage(title: 'Рецепти'),
        "/categoryMeals": (context) => const CategoryMealsPage(),
        "/details": (context) => const DetailsPage(),
        "/favorites": (context) => const FavoritesPage(),
      },
    );
  }
}

