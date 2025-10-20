import 'package:json_annotation/json_annotation.dart';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
part 'bidderDTO.g.dart';

@JsonSerializable()
class BidderDTO {
  final String id;
  final double bid;

  const BidderDTO({
    required this.id,
    required this.bid,
  });

  // Map JSON → DTO
  factory BidderDTO.fromJson(Map<String, dynamic> data) =>
      _$BidderDTOFromJson(data);

  // Map DTO → Domain Entity
  Bidder toEntity() {
    return Bidder(id: id, bid: bid);
  }

  // Map DTO → JSON (for API calls)
  Map<String, dynamic> toJson() => _$BidderDTOToJson(this);
}
