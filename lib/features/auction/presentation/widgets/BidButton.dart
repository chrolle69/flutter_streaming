import 'package:flutter/material.dart';
import 'package:streaming/features/auction/data/models/bidderDTO.dart';
import 'package:streaming/features/auction/data/models/productOfferDTO.dart';
import 'package:streaming/features/auction/presentation/blocs/productState.dart';

class BidButton extends StatelessWidget {
  const BidButton({super.key, required this.prod, required this.productState});

  final ProductOfferDTO prod;
  final ProductState productState;

  @override
  Widget build(BuildContext context) {
    BidderDTO? currentBidder = productState.highestBidder(prod);
    if (currentBidder == null) {
      print("******************currentbidder is null");
    } else {
      print("--------${currentBidder.bid}");
    }

    return ElevatedButton(
      child: Text(
          "bid ${currentBidder == null ? prod.startPrice : prod.increase + currentBidder.bid},-"),
      onPressed: () {
        var bet = currentBidder == null
            ? prod.startPrice
            : prod.increase + currentBidder.bid;

        //productState.addBid(bet, prod.name);
        productState.addBid(bet, prod.name);
      },
    );
  }
}
