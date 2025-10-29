import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';

class RemoveStreamByIdUseCase {
  final StreamRepository repository;

  RemoveStreamByIdUseCase(this.repository);

  Future<DataState<String>> call(String roomId) async {
    return await repository.removeStreamById(roomId);
  }
}
