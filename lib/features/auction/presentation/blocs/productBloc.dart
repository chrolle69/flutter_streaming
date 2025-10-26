import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/data/models/productOfferDTO.dart';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/features/auction/presentation/blocs/productEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/productState.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final StreamRepository streamRep;
  StreamSubscription? _childAddedSub;
  StreamSubscription? _childChangedSub;
  StreamSubscription? _childRemovedSub;

  ProductBloc({required this.streamRep}) : super(ProductState()) {
    // Register the "ProductUpdatedEvent" handler FIRST
    on<ProductUpdatedEvent>(_onProductUpdated);

    // Then the others
    on<InitializeProductListener>(_onInitializeListener);
    on<AddBidEvent>(_onAddBid);
    on<AddProductOfferEvent>(_onAddProductOffer);
  }

  Future<void> _onInitializeListener(
      InitializeProductListener event, Emitter<ProductState> emit) async {
    final roomId = event.roomId;
    final liveStreamRef =
        FirebaseDatabase.instance.ref('liveStreams/$roomId/productOffers');

    await _childAddedSub?.cancel();
    await _childChangedSub?.cancel();
    await _childRemovedSub?.cancel();

    _childAddedSub = liveStreamRef.onChildAdded.listen((e) {
      final data = Map<String, dynamic>.from(e.snapshot.value as Map);
      var product = ProductOfferDTO.fromJson(data).toEntity();
      final updatedList = List<ProductOffer>.from(state.products)..add(product);
      add(ProductUpdatedEvent(updatedList));
    });

    _childChangedSub = liveStreamRef.onChildChanged.listen((e) {
      final data = Map<String, dynamic>.from(e.snapshot.value as Map);
      var updatedProduct = ProductOfferDTO.fromJson(data).toEntity();
      final updatedList = state.products
          .map((p) => p.id == updatedProduct.id ? updatedProduct : p)
          .toList();
      add(ProductUpdatedEvent(updatedList));
    });

    _childRemovedSub = liveStreamRef.onChildRemoved.listen((e) {
      final data = Map<String, dynamic>.from(e.snapshot.value as Map);
      var removedProduct = ProductOfferDTO.fromJson(data).toEntity();
      final updatedList =
          state.products.where((p) => p.id != removedProduct.id).toList();
      add(ProductUpdatedEvent(updatedList));
    });
  }

  void _onProductUpdated(
      ProductUpdatedEvent event, Emitter<ProductState> emit) {
    Map<String, Bidder?> highestBidders = {};
    for (var p in event.products) {
      highestBidders[p.id] = p.getHighestBidder();
    }
    emit(state.copyWith(
        products: event.products, highestBidders: highestBidders));
  }

  void _onAddBid(AddBidEvent event, Emitter<ProductState> emit) {
    print("Adding bid: ${event.bid} for product: ${event.productName}");
    print("Current user id: ${FirebaseAuth.instance.currentUser!.uid}");
    print("Room id: ${event.roomId}");
    streamRep.addBid(FirebaseAuth.instance.currentUser!.uid, event.roomId,
        event.bid, event.productName);
  }

  Future<void> _onAddProductOffer(
      AddProductOfferEvent event, Emitter<ProductState> emit) async {
    final dataState = await streamRep.addProductOffer(
      event.roomId,
      event.name,
      event.description,
      event.type,
      event.size,
      event.color,
      event.startPrice,
      event.increase,
    );

    if (dataState is DataSuccess) {
      emit(state.copyWith(status: ProductStatus.success));
    } else if (dataState is DataError) {
      emit(state.copyWith(
          status: ProductStatus.failure,
          errorMessage: dataState.error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _childAddedSub?.cancel();
    await _childChangedSub?.cancel();
    await _childRemovedSub?.cancel();
    return super.close();
  }
}

// Event
class ProductUpdatedEvent extends ProductEvent {
  final List<ProductOffer> products;
  ProductUpdatedEvent(this.products);
}
