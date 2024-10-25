import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/home/data/models/bidderDTO.dart';
import 'package:streaming/features/home/data/models/productOfferDTO.dart';
import 'package:streaming/features/home/data/models/stream.dart';
import 'package:streaming/features/home/domain/entities/stream.dart';
import 'package:streaming/features/home/domain/stream_repository.dart';
import 'package:http/http.dart' as http;

class StreamRepositoryImpl implements StreamRepository {
  @override
  DataState getAmountOfStreams() {
    var dbRef = FirebaseDatabase.instance.ref();
    var streamList = dbRef.child("liveStreams");

    streamList.get().then((snapshot) {
      if (snapshot.exists) {
        print("\n\nSUCCESS\n\n");
        return DataSuccess(snapshot.children.length);
      } else {
        print("\n\nNO SNAPSHOT\n\n");
        return DataError(Exception("snapshot does not exist"));
      }
    }).onError((error, stackTrace) => DataError(
        HttpException("HTTP failed: \n could not fetch live streams")));

    return DataError(Exception("Should not happend"));
  }

  @override
  Future<DataState> getStreams() async {
    try {
      var dbRef = FirebaseDatabase.instance.ref();
      var streamList = dbRef.child("liveStreams");

      var snapshot = await streamList.get();

      if (snapshot.exists) {
        var data =
            snapshot.children.map((e) => toStreamObject(e.value)).toList();
        print(data.first.toString());
        return DataSuccess(data);
      } else {
        return DataError(Exception("Snapshot does not exist"));
      }
    } catch (e) {
      print("Error fetching streams: $e");
      return DataError(Exception("Failed to fetch live streams"));
    }
  }

  StreamModel toStreamObject(Object? value) {
    if (value is Map<dynamic, dynamic>) {
      var s = StreamModel.fromJson(value);
      return s; // Return the converted StreamModel object
    } else {
      throw Exception("Invalid data type for StreamModel.fromJson");
    }
  }

  @override
  Future<DataState> addStream(
      String title, String description, List<ProductType> types) async {
    try {
      var firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception("User not logged in");
      }

      StreamModel newStream = await addRoom().then((id) {
        print("after return");
        return StreamModel(
            id: id.toString(),
            title: title,
            description: description,
            productTypes: types,
            thumbnail: "fake Thumbnail",
            owner: firebaseUser.uid,
            bidders: [],
            productOffers: []);
      });

      var dbRef = FirebaseDatabase.instance.ref();
      var streamList = dbRef.child("liveStreams");
      await streamList.child(newStream.id).set(newStream.toJson());
      return DataSuccess(newStream);
    } catch (e) {
      print("Error creating room: -$e-");
      return DataError(Exception(e));
    }
  }

  Future<String> addRoom() async {
    var token = dotenv.env['VIDEOSDK_TOKEN']!; // Replace with your actual token

    final http.Response httpResponse = await http.post(
      Uri.parse("https://api.videosdk.live/v2/rooms"),
      headers: {'Authorization': token},
    );
    //Destructuring the roomId from the response
    print("before return");
    return json.decode(httpResponse.body)['roomId'];
  }

  @override
  Future<DataState> getStreamById(String id) async {
    try {
      var streamSnapshot = await FirebaseDatabase.instance
          .ref()
          .child("liveStreams")
          .child(id)
          .get();
      if (streamSnapshot.exists) {
        return DataSuccess(toStreamObject(streamSnapshot.value));
      }
      return DataError(Exception("Stream does not exist"));
    } catch (e) {
      print("Error fetching stream: $e");
      return DataError(Exception("Failed to fetch live stream"));
    }
  }

  @override
  void removeStreamById(String roomId) {
    try {
      FirebaseDatabase.instance
          .ref()
          .child("liveStreams")
          .child(roomId)
          .remove();
    } catch (e) {
      print("Error removing stream: $e");
    }
  }

  @override
  void addProductOffer(String id, String name, ProductType type,
      double startPrice, double increase) {
    print("adding product offer");
    print(type);
    var tmp = ProductOfferDTO(
        id: id,
        name: name,
        type: type,
        startPrice: startPrice,
        increase: increase,
        bidders: []).toJson();
    FirebaseDatabase.instance
        .ref()
        .child("liveStreams")
        .child(id)
        .child("productOffers")
        .child(name)
        .set(tmp);
  }

  @override
  Future<List<ProductOfferDTO>> getProductOffersById(String id) async {
    try {
      var streamSnapshot = await FirebaseDatabase.instance
          .ref()
          .child("liveStreams")
          .child(id)
          .child("productOffers")
          .get();
      if (streamSnapshot.exists) {
        List<ProductOfferDTO> productOffers = streamSnapshot.children
            .map((e) =>
                ProductOfferDTO.fromJson(e.value as Map<dynamic, dynamic>))
            .toList();
        return productOffers;
      }
      throw Exception("No productOffers found");
    } catch (e) {
      print("Error fetching productOffers: $e");
      throw (Exception("Failed to fetch productOffers: $e"));
    }
  }

  @override
  void addBid(String userId, String roomId, double bid, String productName) {
    FirebaseDatabase.instance
        .ref()
        .child("liveStreams")
        .child(roomId)
        .child("productOffers")
        .child(productName)
        .child("bidders")
        .child(userId)
        .set(BidderDTO(id: userId, bid: bid).toJson());
  }

  @override
  Future<DataState> getCurrentBid(String roomId) async {
    try {
      var streamSnapshot = await FirebaseDatabase.instance
          .ref()
          .child("liveStreams")
          .child(roomId)
          .child("bidders")
          .get();
      if (streamSnapshot.exists) {
        List<BidderDTO> bidderList = streamSnapshot.children
            .map((e) => BidderDTO.fromJson(e.value as Map<dynamic, dynamic>))
            .toList();
        bidderList.sort((a, b) => b.bid.compareTo(a.bid));
        return DataSuccess(bidderList.first);
      }
      return DataError(Exception("No bids found"));
    } catch (e) {
      print("Error fetching current bid: $e");
      return DataError(Exception("Failed to fetch current bid"));
    }
  }
}
