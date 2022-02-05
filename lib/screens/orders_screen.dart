import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';
import '../widgets/retry_button.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  Future<void> _refreshOrders(BuildContext context) {
    return Provider.of<Orders>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshOrders(context),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.hasError) {
            return RetryButton(onPressed: () => _refreshOrders(context));
          } else if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => _refreshOrders(context),
              child: Consumer<Orders>(
                builder: (ctx, ordersData, child) =>
                    ordersData.orders.length == 0
                        ? Center(
                            child: Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: ordersData.orders.length,
                            itemBuilder: (ctx, index) {
                              return OrderItem(ordersData.orders[index]);
                            }),
              ),
            );
          }
        },
      ),
    );
  }
}
