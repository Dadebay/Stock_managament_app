import 'package:flutter/material.dart';
import 'package:kartal/kartal.dart';

class ProductCountViewer extends StatelessWidget {
  const ProductCountViewer({super.key, required this.text, required this.totalProducts});
  final String text;
  final String totalProducts;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: context.padding.verticalNormal,
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: context.general.textTheme.bodyLarge!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: context.padding.onlyBottomNormal,
          child: Text(
            totalProducts,
            style: context.general.textTheme.headlineLarge!.copyWith(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ));
  }
}
