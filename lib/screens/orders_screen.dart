import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_complete_guide/widgets/app_drawer.dart';
import 'package:flutter_complete_guide/widgets/order_item.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    print('build orders');
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        body: FutureBuilder(
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                return Text('error occured');
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemBuilder: ((context, index) =>
                        OrderItem(orderData.orders[index])),
                    itemCount: orderData.orders.length,
                  ),
                );
              }
            }
          },
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        ));
  }
}
