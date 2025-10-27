import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/features/auction/domain/usecases/addStreamUseCase.dart';
import 'package:streaming/features/auction/domain/usecases/getStreamByIdUseCase.dart';
import 'package:streaming/features/auction/domain/usecases/getStreamsUseCase.dart';
import 'package:streaming/features/auction/domain/usecases/removeStreamByIdUseCase.dart';
import 'package:streaming/features/auction/presentation/blocs/streamEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/streamState.dart';

class StreamBloc extends Bloc<StreamEvent, StreamState> {
  late final RemoveStreamByIdUseCase removeStreamByIdUseCase;
  late final GetStreamByIdUseCase getStreamByIdUseCase;
  late final AddStreamUseCase addStreamUseCase;
  late final GetStreamsUseCase getStreamsUseCase;

  StreamBloc({required StreamRepository streamRep}) : super(StreamState()) {
    removeStreamByIdUseCase = RemoveStreamByIdUseCase(streamRep);
    getStreamByIdUseCase = GetStreamByIdUseCase(streamRep);
    addStreamUseCase = AddStreamUseCase(streamRep);
    getStreamsUseCase = GetStreamsUseCase(streamRep);
    on<AddTypeEvent>(_onAddType);
    on<RemoveTypeEvent>(_onRemoveType);
    on<SetTitleEvent>(_onSetTitle);
    on<SetDescriptionEvent>(_onSetDescription);
    on<AddStreamEvent>(_onAddStream);
    on<RemoveStreamByIdEvent>(_onRemoveStreamById);
    on<FetchStreamsEvent>(_onFetchStreams);
    on<FetchStreamByIdEvent>(_onFetchStreamById);
    on<CheckStreamAvailableEvent>(_onCheckStreamAvailable);
  }

  void _onAddType(AddTypeEvent event, Emitter<StreamState> emit) {
    emit(state.copyWith(types: [...state.types, event.type]));
  }

  void _onRemoveType(RemoveTypeEvent event, Emitter<StreamState> emit) {
    emit(state.copyWith(
        types: state.types.where((type) => type != event.type).toList()));
  }

  void _onSetTitle(SetTitleEvent event, Emitter<StreamState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onSetDescription(SetDescriptionEvent event, Emitter<StreamState> emit) {
    emit(state.copyWith(description: event.description));
  }

  Future<void> _onAddStream(
      AddStreamEvent event, Emitter<StreamState> emit) async {
    emit(state.copyWith(status: StreamStatus.loading, errorMessage: null));

    if (state.title.isEmpty) {
      emit(state.copyWith(
          status: StreamStatus.failure, errorMessage: "Missing title"));
      return;
    }

    final dataState =
        await addStreamUseCase(state.title, state.description, state.types);

    if (dataState is DataSuccess) {
      emit(state.copyWith(
        selectedStream: dataState.data,
        status: StreamStatus.success,
      ));

      add(FetchStreamsEvent());
    } else if (dataState is DataError) {
      emit(state.copyWith(
        status: StreamStatus.failure,
        errorMessage: dataState.error.toString(),
      ));
    }
  }

  Future<void> _onRemoveStreamById(
      RemoveStreamByIdEvent event, Emitter<StreamState> emit) async {
    emit(state.copyWith(status: StreamStatus.loading, errorMessage: null));

    DataState dataState = await removeStreamByIdUseCase(event.roomId);

    if (dataState is DataSuccess) {
      add(FetchStreamsEvent());
    } else if (dataState is DataError) {
      emit(state.copyWith(
          status: StreamStatus.failure,
          errorMessage: dataState.error.toString()));
    }
  }

  Future<void> _onFetchStreams(
      FetchStreamsEvent event, Emitter<StreamState> emit) async {
    emit(state.copyWith(status: StreamStatus.loading, errorMessage: null));

    DataState dataState = await getStreamsUseCase();

    if (dataState is DataSuccess) {
      emit(state.copyWith(
          streams: dataState.data, status: StreamStatus.success));
    } else if (dataState is DataError) {
      emit(state.copyWith(
          status: StreamStatus.failure,
          errorMessage: dataState.error.toString()));
    }
  }

  Future<void> _onFetchStreamById(
      FetchStreamByIdEvent event, Emitter<StreamState> emit) async {
    emit(state.copyWith(
      status: StreamStatus.loading,
      errorMessage: null,
      selectedStream: null, // clear previous selection
    ));

    DataState dataState = await getStreamByIdUseCase(event.roomId);

    if (dataState is DataSuccess) {
      emit(state.copyWith(
          selectedStream: dataState.data, status: StreamStatus.success));
    } else if (dataState is DataError) {
      emit(state.copyWith(
          status: StreamStatus.failure,
          errorMessage: dataState.error.toString()));
    }
  }

  Future<void> _onCheckStreamAvailable(
      CheckStreamAvailableEvent event, Emitter<StreamState> emit) async {
    emit(state.copyWith(
      availabilityStatus: StreamStatus.loading,
      isStreamAvailable: null,
    ));

    try {
      await getStreamByIdUseCase(event.roomId);
      emit(state.copyWith(
        availabilityStatus: StreamStatus.success,
        isStreamAvailable: true,
      ));
    } catch (_) {
      emit(state.copyWith(
        availabilityStatus: StreamStatus.success,
        isStreamAvailable: false,
      ));
    }
  }
}
