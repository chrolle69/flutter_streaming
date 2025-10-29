import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/shared/data/models/enums.dart';

abstract class ProductEvent {}

class InitializeProductListener extends ProductEvent {
  final String roomId;
  InitializeProductListener({required this.roomId});
}

class AddBidEvent extends ProductEvent {
  final double bid;
  final String productId;
  final String roomId;
  AddBidEvent(this.bid, this.productId, this.roomId);
}

class ProductUpdatedEvent extends ProductEvent {
  final List<ProductOffer> products;
  ProductUpdatedEvent(this.products);
}

class AddProductOfferEvent extends ProductEvent {
  final String roomId;
  final String name;
  final String description;
  final ProductType type;
  final ClothingSize size;
  final SimpleColor color;
  final double startPrice;
  final double increase;

  AddProductOfferEvent({
    required this.roomId,
    required this.name,
    required this.description,
    required this.type,
    required this.size,
    required this.color,
    required this.startPrice,
    required this.increase,
  });
}
