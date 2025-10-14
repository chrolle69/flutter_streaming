import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/home/data/models/enums.dart';
import 'package:streaming/features/home/data/models/productOfferDTO.dart';

abstract class StreamRepository {
  DataState getAmountOfStreams();

  Future<DataState> getStreams();

  Future<DataState> getStreamById(String id);

  Future<DataState> addStream(
      String title, String description, List<ProductType> types);

  void removeStreamById(String roomId);

  void addProductOffer(String id, String name, String descr, ProductType type,
      ClothingSize size, SimpleColor color, double startPrice, double increase);

  Future<List<ProductOfferDTO>> getProductOfferById(String id);

  void removeProductOfferById(String id);

  void addBid(String userId, String roomId, double bid, String productName);

  Future<DataState> getCurrentBid(String roomId);
}
