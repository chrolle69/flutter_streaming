import 'package:equatable/equatable.dart';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/shared/data/models/enums.dart';

class ProductOffer extends Equatable {
  final String id;
  final String name;
  final String descr;
  final ProductType type;
  final ClothingSize size;
  final SimpleColor color;
  final double startPrice;
  final double increase;
  final List<Bidder> bidders;

  const ProductOffer({
    required this.id,
    required this.name,
    required this.descr,
    required this.size,
    required this.color,
    required this.type,
    required this.startPrice,
    required this.increase,
    required this.bidders,
  });

  @override
  List<Object?> get props {
    return [id, name, descr, type, size, color, startPrice, increase, bidders];
  }

  Bidder? getHighestBidder() {
    if (bidders.isEmpty) return null;
    bidders.sort((a, b) => b.bid.compareTo(a.bid));
    print(bidders.first.bid);
    return bidders.first;
  }

  String typeToString() => type.toString().split('.').last;
  String colorToString() => color.toString().split('.').last;
  String sizeToString() => size.toString().split('.').last;
}
