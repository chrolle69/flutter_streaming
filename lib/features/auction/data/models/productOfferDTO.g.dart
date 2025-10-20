// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productOfferDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductOfferDTO _$ProductOfferDTOFromJson(Map<String, dynamic> json) =>
    ProductOfferDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      descr: json['descr'] as String,
      type: $enumDecode(_$ProductTypeEnumMap, json['type']),
      size: $enumDecode(_$ClothingSizeEnumMap, json['size']),
      color: $enumDecode(_$SimpleColorEnumMap, json['color']),
      startPrice: (json['startPrice'] as num).toDouble(),
      increase: (json['increase'] as num).toDouble(),
      bidders: (json['bidders'] as List<dynamic>?)
              ?.map((e) => BidderDTO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$ProductOfferDTOToJson(ProductOfferDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'descr': instance.descr,
      'type': _$ProductTypeEnumMap[instance.type]!,
      'size': _$ClothingSizeEnumMap[instance.size]!,
      'color': _$SimpleColorEnumMap[instance.color]!,
      'startPrice': instance.startPrice,
      'increase': instance.increase,
      'bidders': instance.bidders.map((e) => e.toJson()).toList(),
    };

const _$ProductTypeEnumMap = {
  ProductType.shirt: 'shirt',
  ProductType.jacket: 'jacket',
  ProductType.pants: 'pants',
  ProductType.shoes: 'shoes',
  ProductType.bag: 'bag',
  ProductType.other: 'other',
};

const _$ClothingSizeEnumMap = {
  ClothingSize.XXXS: 'XXXS',
  ClothingSize.XXS: 'XXS',
  ClothingSize.XS: 'XS',
  ClothingSize.S: 'S',
  ClothingSize.M: 'M',
  ClothingSize.L: 'L',
  ClothingSize.XL: 'XL',
  ClothingSize.XXL: 'XXL',
  ClothingSize.XXXL: 'XXXL',
};

const _$SimpleColorEnumMap = {
  SimpleColor.white: 'white',
  SimpleColor.black: 'black',
  SimpleColor.red: 'red',
  SimpleColor.blue: 'blue',
  SimpleColor.green: 'green',
  SimpleColor.yellow: 'yellow',
  SimpleColor.orange: 'orange',
  SimpleColor.purple: 'purple',
  SimpleColor.brown: 'brown',
  SimpleColor.pink: 'pink',
  SimpleColor.gray: 'gray',
  SimpleColor.silver: 'silver',
  SimpleColor.gold: 'gold',
  SimpleColor.other: 'other',
};
