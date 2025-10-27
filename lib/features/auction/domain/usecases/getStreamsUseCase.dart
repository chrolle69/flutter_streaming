import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';

class GetStreamsUseCase {
  final StreamRepository repository;

  GetStreamsUseCase(this.repository);

  Future<DataState> call() async {
    return await repository.getStreams();
  }
}
