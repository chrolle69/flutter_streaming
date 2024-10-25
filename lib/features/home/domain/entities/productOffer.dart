import 'package:equatable/equatable.dart';
import 'package:streaming/features/home/data/models/bidderDTO.dart';
import 'package:streaming/features/home/domain/entities/stream.dart';

class ProductOffer extends Equatable {
  final String id;
  final String name;
  final ProductType type;
  final double startPrice;
  final double increase;
  final List<BidderDTO> bidders;

  const ProductOffer({
    required this.id,
    required this.name,
    required this.type,
    required this.startPrice,
    required this.increase,
    required this.bidders,
  });

  @override
  List<Object?> get props {
    return [id, name, type, startPrice, increase, bidders];
  }
}
