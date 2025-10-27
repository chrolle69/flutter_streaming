import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/shared/data/models/enums.dart';

abstract class StreamRepository {
  Future<DataState> getAmountOfStreams();

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

  Future<DataState> getProductOfferById(String id);

  Future<DataState> removeProductOfferById(String id);

  Future<DataState> addBid(String roomId, double bid, String productName);

  Future<DataState> getCurrentBid(String roomId);
}
