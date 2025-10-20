// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streamDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamDTO _$StreamDTOFromJson(Map<String, dynamic> json) => StreamDTO(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      productTypes: (json['productTypes'] as List<dynamic>)
          .map((e) => $enumDecode(_$ProductTypeEnumMap, e))
          .toList(),
      thumbnail: json['thumbnail'] as String,
      owner: json['owner'] as String,
      bidders: (json['bidders'] as List<dynamic>?)
              ?.map((e) => BidderDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productOffers: (json['productOffers'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, ProductOfferDTO.fromJson(e as Map<String, dynamic>)),
          ) ??
          {},
    );

Map<String, dynamic> _$StreamDTOToJson(StreamDTO instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'productTypes':
          instance.productTypes.map((e) => _$ProductTypeEnumMap[e]!).toList(),
      'thumbnail': instance.thumbnail,
      'owner': instance.owner,
      'bidders': instance.bidders.map((e) => e.toJson()).toList(),
      'productOffers':
          instance.productOffers.map((k, e) => MapEntry(k, e.toJson())),
    };

const _$ProductTypeEnumMap = {
  ProductType.shirt: 'shirt',
  ProductType.jacket: 'jacket',
  ProductType.pants: 'pants',
  ProductType.shoes: 'shoes',
  ProductType.bag: 'bag',
  ProductType.other: 'other',
};
