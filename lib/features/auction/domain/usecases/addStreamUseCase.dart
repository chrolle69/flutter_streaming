import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/shared/data/models/enums.dart';

class AddStreamUseCase {
  final StreamRepository repository;

  AddStreamUseCase(this.repository);

  Future<DataState> call(
      String title, String description, List<ProductType> types) async {
    return await repository.addStream(title, description, types);
  }
}
