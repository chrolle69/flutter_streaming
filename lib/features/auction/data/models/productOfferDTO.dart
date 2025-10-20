import 'package:streaming/features/auction/data/models/bidderDTO.dart';
import 'package:streaming/shared/data/models/enums.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:json_annotation/json_annotation.dart';
part 'productOfferDTO.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductOfferDTO {
  final String id;
  final String name;
  final String descr;
  final ProductType type;
  final ClothingSize size;
  final SimpleColor color;
  final double startPrice;
  final double increase;

  @JsonKey(defaultValue: [])
  final List<BidderDTO> bidders;

  const ProductOfferDTO({
    required this.id,
    required this.name,
    required this.descr,
    required this.type,
    required this.size,
    required this.color,
    required this.startPrice,
    required this.increase,
    required this.bidders,
  });

  factory ProductOfferDTO.fromJson(Map<String, dynamic> data) {
    if (data['bidders'] is List) {
      data['bidders'] = (data['bidders'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return _$ProductOfferDTOFromJson(data);
  }

  Map<String, dynamic> toJson() => _$ProductOfferDTOToJson(this);

  ProductOffer toEntity() {
    return ProductOffer(
      id: id,
      name: name,
      descr: descr,
      type: type,
      size: size,
      color: color,
      startPrice: startPrice,
      increase: increase,
      bidders: bidders.map((b) => b.toEntity()).toList(),
    );
  }
}
