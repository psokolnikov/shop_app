import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite() async {
    final oldValue = isFavorite;
    final newValue = !isFavorite;
    isFavorite = newValue;
    notifyListeners();

    final url = Uri.https(
        'flutter-tutorial-ec5ee-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$id.json');

    try {
      final response = await http.patch(url,
          body: json.encode({
            'isFavorite': newValue,
          }));
      if (response.statusCode >= 400) {
        isFavorite = oldValue;
        notifyListeners();
      }
    }
    catch (error) {
        isFavorite = oldValue;
        notifyListeners();
    }
  }
}
