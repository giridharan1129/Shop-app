import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ProductdetailScreen extends StatelessWidget {
  // final String title;
  // ProductdetailScreen(this.title);
  static const routeNmae = 'product-detail';
  @override
  Widget build(BuildContext context) {
    ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text('title'),
      ),
    );
  }
}
