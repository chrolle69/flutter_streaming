import 'package:flutter/material.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/features/auction/presentation/blocs/productState.dart';

class ProductRowItemOwner extends StatelessWidget {
  const ProductRowItemOwner(
      {super.key, required this.productState, required this.index});

  final ProductState productState;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ProductOffer prod = productState.getProduct(index);

    return Card(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(prod.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ]),
        Text("Higest bid:"),
        Text(
          prod.getHighestBidder() == null
              ? "no bids"
              : "${prod.getHighestBidder()!.bid}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        ElevatedButton(
            onPressed: () => print("do sometinh"), child: Text("does nothing"))
      ]),
    );
  }
}
