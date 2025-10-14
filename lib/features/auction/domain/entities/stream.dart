import 'package:equatable/equatable.dart';
import 'package:streaming/features/auction/data/models/bidderDTO.dart';
import 'package:streaming/shared/data/models/enums.dart';
import 'package:streaming/features/auction/data/models/productOfferDTO.dart';

class Stream extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<ProductType> productTypes;
  final String thumbnail;
  final String owner;
  final List<BidderDTO> bidders;
  final List<ProductOfferDTO> productOffers;

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
