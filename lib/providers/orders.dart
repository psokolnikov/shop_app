import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.datetime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return _orders.toList();
  }

  Future<void> fetchOrders() async {
    final url = Uri.https(
        'flutter-tutorial-ec5ee-default-rtdb.europe-west1.firebasedatabase.app',
        '/orders.json');
    final List<OrderItem> loadedOrders = [];
    final response = await http.get(url);
        print(response.statusCode);
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        datetime: DateTime.parse(orderData['datetime']),
        products: (orderData['products'] as List<dynamic>)
            .map((cartData) => CartItem(
                  id: cartData['id'],
                  title: cartData['title'],
                  quantity: cartData['quantity'],
                  price: cartData['price'],
                ))
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
        'flutter-tutorial-ec5ee-default-rtdb.europe-west1.firebasedatabase.app',
        '/orders.json');
    final timestamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'datetime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList()
          }));
      _orders.insert(
          0,
          new OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            datetime: timestamp,
          ));
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
