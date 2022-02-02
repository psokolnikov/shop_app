import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as o;

class OrderItem extends StatefulWidget {
  final o.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.datetime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(widget.order.products.length * 20.0 + 10, 100),
              child: ListView.builder(
                  itemCount: widget.order.products.length,
                  itemBuilder: (ctx, index) {
                    final product = widget.order.products[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${product.quantity}x \$${product.price}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  }),
            )
        ],
      ),
    );
  }
}
