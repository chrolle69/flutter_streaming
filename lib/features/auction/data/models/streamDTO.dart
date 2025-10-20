import 'package:json_annotation/json_annotation.dart';
import 'package:streaming/features/auction/data/models/bidderDTO.dart';
import 'package:streaming/shared/data/models/enums.dart';
import 'package:streaming/features/auction/data/models/productOfferDTO.dart';
import 'package:streaming/features/auction/domain/entities/stream.dart';

part 'streamDTO.g.dart';

@JsonSerializable(explicitToJson: true)
class StreamDTO {
  final String id;
  final String title;
  final String description;
  final List<ProductType> productTypes;
  final String thumbnail;
  final String owner;

  @JsonKey(defaultValue: [])
  final List<BidderDTO> bidders;

  @JsonKey(defaultValue: {})
  final Map<String, ProductOfferDTO> productOffers;

  const StreamDTO({
    required this.id,
    required this.title,
    required this.description,
    required this.productTypes,
    required this.thumbnail,
    required this.owner,
    required this.bidders,
    required this.productOffers,
  });

  factory StreamDTO.fromJson(Map<String, dynamic> json) {
    return _$StreamDTOFromJson(json);
  }

  Map<String, dynamic> toJson() => _$StreamDTOToJson(this);

  // 👇 Optional helper to get domain entity
  Stream toEntity() => Stream(
        id: id,
        title: title,
        description: description,
        productTypes: productTypes,
        thumbnail: thumbnail,
        owner: owner,
        bidders: bidders.map((b) => b.toEntity()).toList(),
        productOffers: productOffers.values.map((p) => p.toEntity()).toList(),
      );
}
