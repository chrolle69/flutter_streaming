import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';

class GetStreamByIdUseCase {
  final StreamRepository repository;

  GetStreamByIdUseCase(this.repository);

  Future<DataState> call(String id) async {
    return await repository.getStreamById(id);
  }
}
