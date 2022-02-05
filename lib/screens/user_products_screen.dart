import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/retry_button.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) {
    return Provider.of<Products>(context, listen: false).fetchProducts(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.hasError) {
            return RetryButton(onPressed: () => _refreshProducts(context));
          } else if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () => _refreshProducts(context),
              child: Consumer<Products>(
                builder: (ctx, productsData, child) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      final product = productsData.items[index];
                      return Column(
                        children: [
                          UserProductItem(
                              product.id, product.title, product.imageUrl),
                          Divider(),
                        ],
                      );
                    },
                    itemCount: productsData.items.length,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
