import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/features/auction/domain/entities/stream.dart';
import 'package:streaming/shared/data/models/enums.dart';

class AddStreamUseCase {
  final StreamRepository repository;

  AddStreamUseCase(this.repository);

  Future<DataState<Stream>> call(
      String title, String description, List<ProductType> types) async {
    return repository.addStream(title, description, types);
  }
}
