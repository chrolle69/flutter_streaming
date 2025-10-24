import 'package:streaming/shared/data/models/enums.dart';
import 'package:streaming/features/auction/domain/entities/stream.dart';

enum StreamStatus { initial, loading, success, failure }

class StreamState {
  final String title;
  final String description;
  final Stream? selectedStream;
  final List<ProductType> types;
  final List<Stream> streams;
  final StreamStatus status;
  final String? errorMessage;
  final bool? isStreamAvailable;
  final StreamStatus availabilityStatus;

  const StreamState({
    this.title = "",
    this.description = "",
    this.selectedStream,
    this.types = const [],
    this.streams = const [],
    this.status = StreamStatus.initial,
    this.errorMessage,
    this.isStreamAvailable,
    this.availabilityStatus = StreamStatus.initial,
  });

  StreamState copyWith({
    String? title,
    String? description,
    Stream? selectedStream,
    List<ProductType>? types,
    List<Stream>? streams,
    StreamStatus? status,
    String? errorMessage,
    bool? isStreamAvailable,
    StreamStatus? availabilityStatus,
  }) {
    return StreamState(
      title: title ?? this.title,
      description: description ?? this.description,
      selectedStream: selectedStream ?? this.selectedStream,
      types: types ?? this.types,
      streams: streams ?? this.streams,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isStreamAvailable: isStreamAvailable ?? this.isStreamAvailable,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    );
  }
}
