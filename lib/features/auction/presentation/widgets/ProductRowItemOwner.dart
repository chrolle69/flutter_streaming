import 'package:flutter/material.dart';
import 'package:streaming/features/home/data/models/productOfferDTO.dart';
import 'package:streaming/features/home/presentation/blocs/productState.dart';

class ProductRowItemOwner extends StatelessWidget {
  const ProductRowItemOwner(
      {super.key, required this.productState, required this.index});

  final ProductState productState;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ProductOfferDTO prod = productState.getProduct(index);

    return Card(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text("${prod.name}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ]),
        Text("Higest bid:"),
        Text(
          prod.highestBidder() == null
              ? "no bids"
              : "${prod.highestBidder()!.bid}",
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
