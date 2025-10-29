import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:streaming/features/auction/data/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class RemoteDataSourceAWS {
  final DatabaseReference db;

  RemoteDataSourceAWS({required this.db});

  Future<DataSnapshot> getStreams() async {
    try {
      final snapshot = await db.child("liveStreams").get();
      if (!snapshot.exists) {
        throw SnapshotNotFoundException("No streams available");
      }
      return snapshot;
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Could not connect to server");
    } catch (e) {
      throw DatabaseConnectionException("Failed to fetch live streams");
    }
  }

  Future<void> addStream(
      Map<String, dynamic> streamJSON, String streamId) async {
    try {
      await db.child("liveStreams").child(streamId).set(streamJSON);
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Failed to add stream");
    } catch (e) {
      throw DatabaseConnectionException("Unknown error adding stream");
    }
  }

  Future<String> addRoom(String token) async {
    try {
      final http.Response httpResponse = await http.post(
        Uri.parse("https://api.videosdk.live/v2/rooms"),
        headers: {'Authorization': token},
      );
      var data = json.decode(httpResponse.body);
      if (data['roomId'] == null) {
        throw RoomDecodingException("roomId not found in response");
      }
      return data['roomId'];
    } on RoomHttpException catch (_) {
      rethrow;
    } catch (e) {
      throw RoomCreationException("Unexpected error creating room: $e");
    }
  }

  Future<DataSnapshot> getStreamById(String id) async {
    try {
      var snapshot = await db.child("liveStreams").child(id).get();
      if (!snapshot.exists) {
        throw SnapshotNotFoundException("Stream does not exist");
      }
      return snapshot;
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Failed to connect to server");
    } catch (e) {
      throw Exception("Unexpected error fetching stream: $e");
    }
  }

  Future<void> removeStreamById(String roomId) async {
    try {
      db.child("liveStreams").child(roomId).remove();
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Failed to end stream");
    } catch (e) {
      throw Exception("Unexpected error while removing stream: $e");
    }
  }

  Future<void> addProductOffer(Map<String, dynamic> productOfferJSON,
      String roomId, String productOfferId) async {
    try {
      db
          .child("liveStreams")
          .child(roomId)
          .child("productOffers")
          .child(productOfferId)
          .set(productOfferJSON);
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Failed to add product");
    } catch (e) {
      throw Exception("Unexpected error while adding product: $e");
    }
  }

  Future<DataSnapshot> getProductOfferById(String id) async {
    try {
      var snapshot =
          await db.child("liveStreams").child(id).child("productOffers").get();
      if (!snapshot.exists) {
        throw SnapshotNotFoundException("Product does not exist");
      }
      return snapshot;
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Failed to fetch product");
    } catch (e) {
      throw Exception("Unexpected error while fetching product: $e");
    }
  }

  Future<void> removeProductOfferById(String id) async {
    try {
      await db.child("liveStreams").child(id).child("productOffers").remove();
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Failed to remove product");
    } catch (e) {
      throw Exception("Unexpected error while deleting product: $e");
    }
  }

  Future<void> addBid(
      Map<String, dynamic> bidder, String roomId, String productId) async {
    try {
      db
          .child("liveStreams")
          .child(roomId)
          .child("productOffers")
          .child(productId)
          .child("bidders")
          .set([bidder]);

      await FirebaseDatabase.instance
          .ref()
          .child("liveStreams")
          .child(roomId)
          .child("bidders")
          .set([bidder]);
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Failed to add bid");
    } catch (e) {
      throw Exception("Unexpected error while adding bid: $e");
    }
  }

  Future<DataSnapshot> getBids(String roomId) async {
    try {
      var snapshot =
          await db.child("liveStreams").child(roomId).child("bidders").get();
      if (!snapshot.exists) {
        throw SnapshotNotFoundException("No bidders found");
      }
      return snapshot;
    } on FirebaseException catch (_) {
      throw DatabaseConnectionException("Failed to fetch bidders");
    } catch (e) {
      throw Exception("Unexpected error while fetching bidders: $e");
    }
  }
}
