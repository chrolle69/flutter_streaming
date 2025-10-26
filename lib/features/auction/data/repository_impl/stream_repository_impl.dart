import 'dart:convert';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/features/auction/domain/entities/stream.dart';
import 'package:streaming/shared/data/models/enums.dart';
import 'package:streaming/core/util/map_utils.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/data/models/bidderDTO.dart';
import 'package:streaming/features/auction/data/models/productOfferDTO.dart';
import 'package:streaming/features/auction/data/models/streamDTO.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:http/http.dart' as http;

class StreamRepositoryImpl implements StreamRepository {
  @override
  DataState getAmountOfStreams() {
    var dbRef = FirebaseDatabase.instance.ref();
    var streamList = dbRef.child("liveStreams");

    streamList.get().then((snapshot) {
      if (snapshot.exists) {
        return DataSuccess(snapshot.children.length);
      } else {
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
        var streams = snapshot.children.map((e) {
          final json = convertDynamicMapToStringMap(e.value as Map);
          return StreamDTO.fromJson(json).toEntity();
        }).toList();

        return DataSuccess(streams);
      } else {
        print("No snapshot exists");
        return DataSuccess(<Stream>[]);
      }
    } catch (e) {
      print("Error fetching streams: $e");
      return DataError(Exception("Failed to fetch live streams"));
    }
  }

  Stream toStreamObject(Object? value) {
    if (value is Map<dynamic, dynamic>) {
      return StreamDTO.fromJson(convertDynamicMapToStringMap(value)).toEntity();
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

      StreamDTO newStream = await addRoom().then((id) {
        return StreamDTO(
            id: id.toString(),
            title: title,
            description: description,
            productTypes: types,
            thumbnail: "fake Thumbnail",
            owner: firebaseUser.uid,
            bidders: [],
            productOffers: {});
      });

      var dbRef = FirebaseDatabase.instance.ref();
      var streamList = dbRef.child("liveStreams");
      await streamList.child(newStream.id).set(newStream.toJson());
      return DataSuccess(newStream.toEntity());
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
  Future<DataState> removeStreamById(String roomId) async {
    try {
      await FirebaseDatabase.instance
          .ref()
          .child("liveStreams")
          .child(roomId)
          .remove();
      return DataSuccess(true);
    } catch (e) {
      print("Error removing stream: $e");
      return DataError(Exception("Failed to remove live stream by ID"));
    }
  }

  @override
  Future<DataState> addProductOffer(
      String id,
      String name,
      String descr,
      ProductType type,
      ClothingSize size,
      SimpleColor color,
      double startPrice,
      double increase) async {
    var uuid = Uuid().v1();
    var tmp = {};
    try {
      tmp = ProductOfferDTO(
          id: uuid,
          name: name,
          descr: descr,
          type: type,
          size: size,
          color: color,
          startPrice: startPrice,
          increase: increase,
          bidders: []).toJson();
    } catch (e) {
      print("Error creating product offer: $e");
      return DataError(Exception("Failed to create product offer"));
    }
    try {
      FirebaseDatabase.instance
          .ref()
          .child("liveStreams")
          .child(id)
          .child("productOffers")
          .child(name)
          .set(tmp);
    } catch (e) {
      print("Error adding product offer: $e");
      return DataError(Exception("Failed to add product offer"));
    }
    return DataSuccess(true);
  }

  @override
  Future<List<ProductOffer>> getProductOfferById(String id) async {
    try {
      var streamSnapshot = await FirebaseDatabase.instance
          .ref()
          .child("liveStreams")
          .child(id)
          .child("productOffers")
          .get();
      if (streamSnapshot.exists) {
        List<ProductOffer> productOffers = streamSnapshot.children.map((e) {
          final json = convertDynamicMapToStringMap(e.value as Map);
          return ProductOfferDTO.fromJson(json).toEntity();
        }).toList();

        return productOffers;
      }
      throw Exception("No productOffers found");
    } catch (e) {
      print("Error fetching productOffers: $e");
      throw (Exception("Failed to fetch productOffers: $e"));
    }
  }

  @override
  void removeProductOfferById(String id) async {
    FirebaseDatabase.instance
        .ref()
        .child("liveStreams")
        .child(id)
        .child("productOffers")
        .remove();
  }

  @override
  void addBid(String userId, String roomId, double bid, String productName) {
    final bidder = BidderDTO(id: userId, bid: bid).toJson();
    FirebaseDatabase.instance
        .ref()
        .child("liveStreams")
        .child(roomId)
        .child("productOffers")
        .child(productName)
        .child("bidders")
        .set([bidder]);

    FirebaseDatabase.instance
        .ref()
        .child("liveStreams")
        .child(roomId)
        .child("bidders")
        .set([bidder]);
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
        List<Bidder> bidderList = streamSnapshot.children.map((e) {
          return BidderDTO.fromJson(e.value as Map<String, dynamic>).toEntity();
        }).toList();

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
