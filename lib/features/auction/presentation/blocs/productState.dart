import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:streaming/features/home/data/models/bidderDTO.dart';
import 'package:streaming/features/home/data/models/productOfferDTO.dart';
import 'package:streaming/features/home/data/repository/stream_repository_impl.dart';
import 'package:streaming/features/home/domain/stream_repository.dart';

class ProductState extends ChangeNotifier {
  StreamRepository streamRep = StreamRepositoryImpl();
  String roomId;
  List<ProductOfferDTO> productList = [];

  ProductState(this.roomId) {
    createListeners();
  }

  void createListeners() {
    var liveStreamRef =
        FirebaseDatabase.instance.ref('liveStreams/$roomId/productOffers');
    FirebaseDatabase.instance.ref().keepSynced(true);

    liveStreamRef.onChildAdded.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print(data is Map<dynamic, dynamic>);

      var product = ProductOfferDTO.fromJson(data as Map<dynamic, dynamic>);
      productList.add(product);
      print(productList.first);
      print("notifying lesteners");
      notifyListeners();
    });

    liveStreamRef.onChildChanged.listen((event) {
      final data = event.snapshot.value;
      var newP = ProductOfferDTO.fromJson(data as Map<dynamic, dynamic>);
      var currentP = productList.firstWhere((p) => p.id == newP.id);
      int i = productList.indexOf(currentP);
      if (i == -1) {
        productList.add(newP);
      } else {
        productList[i] = newP;
      }
      print("notifying lesteners");
      notifyListeners();
    });
    liveStreamRef.onChildRemoved.listen((event) {
      final data = event.snapshot.value;
      var newP = ProductOfferDTO.fromJson(data as Map<dynamic, dynamic>);
      var currentP = productList.firstWhere((p) => p.id == newP.id);
      int i = productList.indexOf(currentP);
      if (i != -1) {
        productList.removeAt(i);
        notifyListeners();
      }
    });
    print("---------- event happend ------------");
  }

  void addBid(double bid, String productName) {
    streamRep.addBid(getUser().uid, roomId, bid, productName);
    print("...... placed bid");
  }

  BidderDTO? highestBidder(ProductOfferDTO prod) {
    return prod.highestBidder();
  }

  List<ProductOfferDTO> getProducts() {
    return productList;
  }

  ProductOfferDTO getProduct(int i) {
    return productList[i];
  }

  User getUser() {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("ID not found");
    return user;
  }
}
