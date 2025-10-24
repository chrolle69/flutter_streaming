import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:streaming/features/auction/data/models/productOfferDTO.dart';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/shared/data/models/enums.dart';

class ProductState extends ChangeNotifier {
  final StreamRepository streamRep;
  String roomId;
  List<ProductOffer> productList = [];

  ProductState({required this.roomId, required this.streamRep}) {
    createListeners();
  }

  void createListeners() {
    var liveStreamRef =
        FirebaseDatabase.instance.ref('liveStreams/$roomId/productOffers');
    FirebaseDatabase.instance.ref().keepSynced(true);

    liveStreamRef.onChildAdded.listen((DatabaseEvent event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      var product = ProductOfferDTO.fromJson(data);
      productList.add(product.toEntity());

      notifyListeners();
    });

    liveStreamRef.onChildChanged.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      var newP = ProductOfferDTO.fromJson(data);

      var currentP = productList.firstWhere((p) => p.id == newP.id);
      int i = productList.indexOf(currentP);
      if (i == -1) {
        productList.add(newP.toEntity());
      } else {
        productList[i] = newP.toEntity();
      }
      notifyListeners();
    });
    liveStreamRef.onChildRemoved.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      var newP = ProductOfferDTO.fromJson(data);
      var currentP = productList.firstWhere((p) => p.id == newP.id);
      int i = productList.indexOf(currentP);
      if (i != -1) {
        productList.removeAt(i);
        notifyListeners();
      }
    });
  }

  void addBid(double bid, String productName) {
    streamRep.addBid(getUser().uid, roomId, bid, productName);
  }

  Bidder? highestBidder(ProductOffer prod) {
    return prod.getHighestBidder();
  }

  List<ProductOffer> getProducts() {
    return productList;
  }

  ProductOffer getProduct(int i) {
    return productList[i];
  }

  Future<bool> addProductOffer(
      String roomId,
      String productName,
      String productDescr,
      ProductType productType,
      ClothingSize size,
      SimpleColor color,
      double startPrice,
      double increase) async {
    try {
      streamRep.addProductOffer(roomId, productName, productDescr, productType,
          size, color, startPrice, increase);
      return true;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  User getUser() {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("ID not found");
    return user;
  }
}
