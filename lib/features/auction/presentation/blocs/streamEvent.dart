import 'package:streaming/shared/data/models/enums.dart';

abstract class StreamEvent {}

class AddTypeEvent extends StreamEvent {
  final ProductType type;
  AddTypeEvent({required this.type});
}

class RemoveTypeEvent extends StreamEvent {
  final ProductType type;
  RemoveTypeEvent({required this.type});
}

class SetTitleEvent extends StreamEvent {
  final String title;
  SetTitleEvent({required this.title});
}

class SetDescriptionEvent extends StreamEvent {
  final String description;
  SetDescriptionEvent({required this.description});
}

class SetLoadingEvent extends StreamEvent {
  final bool isLoading;
  SetLoadingEvent({required this.isLoading});
}

class RemoveStreamByIdEvent extends StreamEvent {
  final String roomId;
  RemoveStreamByIdEvent({required this.roomId});
}

class AddStreamEvent extends StreamEvent {}

class FetchStreamsEvent extends StreamEvent {}

class FetchStreamByIdEvent extends StreamEvent {
  final String roomId;
  FetchStreamByIdEvent({required this.roomId});
}

class CheckStreamAvailableEvent extends StreamEvent {
  final String roomId;
  CheckStreamAvailableEvent({required this.roomId});
}
