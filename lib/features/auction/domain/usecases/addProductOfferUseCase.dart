import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/shared/data/models/enums.dart';

class AddProductOfferUseCase {
  final StreamRepository repository;

  AddProductOfferUseCase(this.repository);

  Future<DataState> call(
      String roomId,
      String name,
      String descr,
      ProductType type,
      ClothingSize size,
      SimpleColor color,
      double startPrice,
      double increase) async {
    return await repository.addProductOffer(
        roomId, name, descr, type, size, color, startPrice, increase);
  }
}
