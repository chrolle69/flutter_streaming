import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/features/auction/domain/entities/stream.dart';
import 'package:streaming/shared/data/models/enums.dart';

abstract class StreamRepository {
  Future<DataState<int>> getAmountOfStreams();

  Future<DataState<List<Stream>>> getStreams();

  Future<DataState<Stream>> getStreamById(String id);

  Future<DataState<Stream>> addStream(
      String title, String description, List<ProductType> types);

  Future<DataState<String>> removeStreamById(String roomId);

  Future<DataState<ProductOffer>> addProductOffer(
      String id,
      String name,
      String descr,
      ProductType type,
      ClothingSize size,
      SimpleColor color,
      double startPrice,
      double increase);

  Future<DataState<List<ProductOffer>>> getProductOfferById(String id);

  Future<DataState<String>> removeProductOfferById(String id);

  Future<DataState<String>> addBid(String roomId, double bid, String productId);

  Future<DataState<Bidder>> getCurrentBid(String roomId);
}
