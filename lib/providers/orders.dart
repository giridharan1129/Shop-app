import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItems {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItems(
      {@required this.amount,
      @required this.dateTime,
      @required this.id,
      @required this.products});
}

class Orders with ChangeNotifier {
  List<OrderItems> _orders = [];

  List<OrderItems> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://shop-app-3b391-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json');
    final response = await http.get(url);
    List<OrderItems> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItems(
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          id: orderId,
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price']))
              .toList()));
    });
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop-app-3b391-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json');
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toString(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title.characters.toString(),
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList(),
        }));
    _orders.insert(
        0,
        OrderItems(
            amount: total,
            dateTime: DateTime.now(),
            id: json.decode(response.body)['name'],
            products: cartProducts));
    notifyListeners();
  }
}
