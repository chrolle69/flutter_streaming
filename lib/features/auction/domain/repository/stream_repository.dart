import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/shared/data/models/enums.dart';

abstract class StreamRepository {
  DataState getAmountOfStreams();

  Future<DataState> getStreams();

  Future<DataState> getStreamById(String id);

  Future<DataState> addStream(
      String title, String description, List<ProductType> types);

  Future<DataState> removeStreamById(String roomId);

  Future<DataState> addProductOffer(
      String id,
      String name,
      String descr,
      ProductType type,
      ClothingSize size,
      SimpleColor color,
      double startPrice,
      double increase);

  Future<List<ProductOffer>> getProductOfferById(String id);

  void removeProductOfferById(String id);

  void addBid(String userId, String roomId, double bid, String productName);

  Future<DataState> getCurrentBid(String roomId);
}
