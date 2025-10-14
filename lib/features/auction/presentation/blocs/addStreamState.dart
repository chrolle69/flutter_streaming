import 'package:flutter/material.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/shared/data/models/enums.dart';
import 'package:streaming/features/auction/data/repository/stream_repository_impl.dart';
import 'package:streaming/features/auction/domain/stream_repository.dart';

class AddStreamState extends ChangeNotifier {
  StreamRepository streamRep = StreamRepositoryImpl();
  String title = "";
  String description = "";
  List<ProductType> types = [];

  void addType(ProductType type) {
    types.add(type);
    notifyListeners();
  }

  void removeType(ProductType type) {
    types.remove(type);
    notifyListeners();
  }

  void setTitle(String str) {
    title = str;
    notifyListeners();
  }

  void setDescription(String str) {
    description = str;
    notifyListeners();
  }

  bool contains(ProductType type) {
    return types.contains(type);
  }

  Future<DataState> addStream() async {
    if (title.isEmpty) {
      return DataError(Exception("missing Title"));
    }
    return await streamRep.addStream(title, description, types);
  }
}
