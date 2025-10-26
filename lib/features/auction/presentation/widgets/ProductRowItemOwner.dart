import 'package:flutter/material.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';

class ProductRowItemOwner extends StatelessWidget {
  const ProductRowItemOwner({super.key, required this.productOffer});

  final ProductOffer productOffer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(productOffer.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ]),
        Text("Higest bid:"),
        Text(
          productOffer.getHighestBidder() == null
              ? "no bids"
              : "${productOffer.getHighestBidder()!.bid}",
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
