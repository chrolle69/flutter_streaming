import 'package:streaming/features/home/data/models/bidderDTO.dart';
import 'package:streaming/features/home/data/models/enums.dart';
import 'package:streaming/features/home/data/models/productOfferDTO.dart';
import 'package:streaming/features/home/domain/entities/stream.dart';

class StreamModel extends Stream {
  const StreamModel(
      {required super.id,
      required super.title,
      required super.description,
      required super.productTypes,
      required super.thumbnail,
      required super.owner,
      required super.bidders,
      required super.productOffers});

  factory StreamModel.fromJson(Map<dynamic, dynamic> data) {
    List<ProductType> productTypesResult = [];
    List<BidderDTO> biddersListResult = [];
    List<ProductOfferDTO> productOffersResult = [];

    try {
      var productOffersList = data['productOffers'] as List<dynamic>?;
      if (productOffersList != null) {
        productOffersResult =
            productOffersList.where((e) => e != null).map((e) {
          if (e is ProductOfferDTO) {
            return e;
          } else {
            throw FormatException("Invalid ProductOffer format: $e");
          }
        }).toList();
      }

      var productTypesList = data['productTypes'] as List<dynamic>?;
      if (productTypesList != null) {
        productTypesResult = productTypesList.where((e) => e != null).map((e) {
          if (e is int) {
            return ProductType.values[e];
          } else {
            throw FormatException("Invalid product type value: $e");
          }
        }).toList();
      } else {
        print("ProductTypes List is null or missing");
      }

      var biddersList = data['bidders'] as List<dynamic>?;
      if (biddersList != null) {
        biddersListResult = biddersList.where((e) => e != null).map((e) {
          if (e is BidderDTO) {
            return e;
          } else {
            throw FormatException("Invalid Bidder format: $e");
          }
        }).toList();
      }
    } catch (e) {
      print("Error while mapping product types: $e");
    }

    var s = StreamModel(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        productTypes: productTypesResult,
        thumbnail: data['thumbnail'],
        owner: data['owner'],
        bidders: biddersListResult,
        productOffers: productOffersResult);
    return s;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "productTypes": productTypes.map((x) => x.index).toList(),
        "thumbnail": thumbnail,
        "owner": owner,
        "bidders": bidders
      };
}

extension ProductTypeExtension on ProductType {
  static ProductType fromString(String value) {
    return ProductType.values
        .firstWhere((e) => e.toString().split('.').last == value);
  }
}
