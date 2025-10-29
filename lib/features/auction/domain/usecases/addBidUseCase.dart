import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';

class AddBidUseCase {
  final StreamRepository repository;

  AddBidUseCase(this.repository);

  Future<DataState<String>> call(
      String roomId, double amount, String productId) async {
    return await repository.addBid(roomId, amount, productId);
  }
}
