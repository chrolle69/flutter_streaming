// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bidderDTO.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BidderDTO _$BidderDTOFromJson(Map<String, dynamic> json) => BidderDTO(
      id: json['id'] as String,
      bid: (json['bid'] as num).toDouble(),
    );

Map<String, dynamic> _$BidderDTOToJson(BidderDTO instance) => <String, dynamic>{
      'id': instance.id,
      'bid': instance.bid,
    };
