import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product.dart';

class Products with ChangeNotifier {
  final String? authToken;
  final String? userId;
  List<Product> _items;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return _items.toList();
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Future<void> fetchProducts({bool filterByUser = false}) async {
    final queryParameters = filterByUser
        ? {
            'auth': authToken,
            'orderBy': json.encode('userId'),
            'equalTo': json.encode(userId)
          }
        : {
            'auth': authToken,
          };

    final productsUrl = Uri.https(
      'flutter-tutorial-ec5ee-default-rtdb.europe-west1.firebasedatabase.app',
      '/products.json',
      queryParameters,
    );

    final favoritesUrl = Uri.https(
        'flutter-tutorial-ec5ee-default-rtdb.europe-west1.firebasedatabase.app',
        '/favorites/${userId}.json',
        {'auth': authToken});

    try {
      final List<Product> loadedProducts = [];
      final response = await http.get(productsUrl);
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      if (extractedData == null) {
        _items.clear();
        return;
      }

      final favoriteResponse = await http.get(favoritesUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite:
              favoriteData != null && (favoriteData[productId] ?? false),
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
        'flutter-tutorial-ec5ee-default-rtdb.europe-west1.firebasedatabase.app',
        '/products.json',
        {'auth': authToken});

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'userId': userId,
          }));
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    final url = Uri.https(
        'flutter-tutorial-ec5ee-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/${product.id}.json',
        {'auth': authToken});
    await http.patch(url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        }));
    var index = _items.indexWhere((item) => item.id == product.id);
    _items[index] = product;
    notifyListeners();
  }

  Product findById(String id) {
    return _items.singleWhere((product) => product.id == id);
  }

  Future<void> deleteProduct(String id) async {
    final deletingProductIndex = _items.indexWhere((item) => item.id == id);
    final deletingProduct = _items[deletingProductIndex];
    _items.removeWhere((item) => item.id == id);
    notifyListeners();

    final url = Uri.https(
        'flutter-tutorial-ec5ee-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/${deletingProduct.id}.json',
        {'auth': authToken});
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(deletingProductIndex, deletingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
  }
}
