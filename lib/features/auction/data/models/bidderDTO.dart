import 'package:streaming/features/auction/domain/entities/bidder.dart';

class BidderDTO extends Bidder {
  const BidderDTO({
    required super.id,
    required super.bid,
  });

  factory BidderDTO.fromJson(Map<dynamic, dynamic> data) {
    print(",,,is doing fromjson");
    // Handle bid value as int or double
    double bid =
        (data['bid'] is int) ? (data['bid'] as int).toDouble() : data['bid'];

    var s = BidderDTO(id: data['id'], bid: bid);
    return s;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "bid": bid,
      };
}
