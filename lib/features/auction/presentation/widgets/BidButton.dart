import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/features/auction/presentation/blocs/productBloc.dart';
import 'package:streaming/features/auction/presentation/blocs/productEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/productState.dart';

class BidButton extends StatelessWidget {
  const BidButton(
      {super.key,
      required this.prod,
      required this.productState,
      required this.roomId});

  final ProductOffer prod;
  final ProductState productState;
  final String roomId;

  @override
  Widget build(BuildContext context) {
    Bidder? currentBidder =
        context.read<ProductBloc>().state.highestBidders[prod.id];
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
        print("Placing bid of $bet on product ${prod.name} in room $roomId");
        //productState.addBid(bet, prod.name);
        context.read<ProductBloc>().add(AddBidEvent(
              bet,
              prod.id,
              roomId,
            ));
      },
    );
  }
}
