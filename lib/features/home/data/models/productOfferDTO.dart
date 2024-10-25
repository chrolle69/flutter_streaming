import 'package:streaming/features/home/data/models/bidderDTO.dart';
import 'package:streaming/features/home/domain/entities/productOffer.dart';
import 'package:streaming/features/home/domain/entities/stream.dart';

class ProductOfferDTO extends ProductOffer {
  const ProductOfferDTO({
    required super.id,
    required super.name,
    required super.type,
    required super.startPrice,
    required super.increase,
    required super.bidders,
  });

  factory ProductOfferDTO.fromJson(Map<dynamic, dynamic> data) {
    List<BidderDTO> biddersListResult = [];
    print(".....................making product");
    print("inside test::   " + data['bidders'].toString());
    try {
      // Cast bidders to a List<dynamic>
      var biddersMap = data['bidders'] as Map<dynamic, dynamic>;

      print(biddersMap.toString());
      if (biddersMap.isNotEmpty) {
        biddersListResult = biddersMap.entries.map((entry) {
          var id = entry.value['id'];
          var bid = entry.value['bid'];
          // Handle potential type casting issues here, if needed. For now, we just assume the bid is a double.
          return BidderDTO(id: id, bid: bid is int ? bid.toDouble() : bid);
        }).toList();
      }
    } catch (e) {
      print("Error while mapping bidders: $e");
    }
    print("bidderlist:" + biddersListResult.toString());
    // Handle startPrice and increase that could be int or double
    double startPrice = (data['startPrice'] is int)
        ? (data['startPrice'] as int).toDouble()
        : data['startPrice'];
    double increase = (data['increase'] is int)
        ? (data['increase'] as int).toDouble()
        : data['increase'];

    var s = ProductOfferDTO(
        id: data['id'],
        name: data['name'],
        type: ProductType.values[data['type']],
        startPrice: startPrice,
        increase: increase,
        bidders: biddersListResult);
    print("done method: " + s.toString());
    return s;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type.index,
        "startPrice": startPrice,
        "increase": increase,
        "bidders": bidders
      };

  BidderDTO? highestBidder() {
    if (bidders.isEmpty) return null;
    return bidders
        .reduce((max, current) => max.bid > current.bid ? max : current);
  }
}
