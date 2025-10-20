import 'package:equatable/equatable.dart';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/shared/data/models/enums.dart';

class Stream extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<ProductType> productTypes;
  final String thumbnail;
  final String owner;
  final List<Bidder> bidders;
  final List<ProductOffer> productOffers;

  const Stream({
    required this.id,
    required this.title,
    required this.description,
    required this.productTypes,
    required this.thumbnail,
    required this.owner,
    required this.bidders,
    required this.productOffers,
  });

  @override
  List<Object?> get props {
    return [
      id,
      title,
      description,
      productTypes,
      thumbnail,
      owner,
      bidders,
      productOffers
    ];
  }
}
