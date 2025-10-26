import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState {
  final ProductStatus status;
  final List<ProductOffer> products;
  final Map<String, Bidder?> highestBidders;
  final String? errorMessage;

  ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.highestBidders = const {},
    this.errorMessage,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<ProductOffer>? products,
    Map<String, Bidder?>? highestBidders,
    String? errorMessage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      highestBidders: highestBidders ?? this.highestBidders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
