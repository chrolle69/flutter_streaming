import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:dio/dio.dart';
import 'package:streaming/features/auction/data/data_sources/remote/remote_data_source_aws.dart';
import 'package:streaming/features/auction/data/data_sources/remote/remote_data_source_firebase.dart';
import 'package:streaming/features/auction/data/exceptions.dart';
import 'package:streaming/features/auction/domain/entities/bidder.dart';
import 'package:streaming/features/auction/domain/entities/productOffer.dart';
import 'package:streaming/features/auction/domain/entities/stream.dart';
import 'package:streaming/shared/data/models/enums.dart';
import 'package:streaming/core/util/map_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/data/models/bidderDTO.dart';
import 'package:streaming/features/auction/data/models/productOfferDTO.dart';
import 'package:streaming/features/auction/data/models/streamDTO.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';

class StreamRepositoryImpl implements StreamRepository {
  final RemoteDataSourceFirebase firebase;
  final RemoteDataSourceAWS aws;

  StreamRepositoryImpl(this.firebase, this.aws);

  @override
  Future<DataState<int>> getAmountOfStreams() async {
    try {
      var snapshot = await firebase.getStreams();
      return DataSuccess(snapshot.children.length);
    } on SnapshotNotFoundException catch (_) {
      return DataSuccess(0);
    } on Exception catch (e) {
      return DataError(e);
    }
  }

  @override
  Future<DataState<List<Stream>>> getStreams() async {
    try {
      var snapshot = await firebase.getStreams();

      var streams = snapshot.children.map((e) {
        final json = convertDynamicMapToStringMap(e.value as Map);
        return StreamDTO.fromJson(json).toEntity();
      }).toList();

      return DataSuccess(streams);
    } on SnapshotNotFoundException catch (_) {
      return DataSuccess([]);
    } on Exception catch (e) {
      return DataError(e);
    }
  }

  Stream toStreamObject(Object? value) {
    if (value is Map<dynamic, dynamic>) {
      return StreamDTO.fromJson(convertDynamicMapToStringMap(value)).toEntity();
    } else {
      throw ObjectException("Invalid data type for StreamModel.fromJson");
    }
  }

  @override
  Future<DataState<Stream>> addStream(
      String title, String description, List<ProductType> types) async {
    try {
      //var user = await getFirebaseUser();
      var user = await getAWSUser();
      if (!await isAWSUserSignedIn()) {
        throw UserNotFoundException("User must be logged in");
      }
      print("userid----------${user.userId}--------");
      StreamDTO newStream = await addRoom().then((id) {
        return StreamDTO(
            id: id.toString(),
            title: title,
            description: description,
            productTypes: types,
            thumbnail: "fake Thumbnail",
            owner: user.userId,
            bidders: [],
            productOffers: {});
      });

      await firebase.addStream(newStream.toJson(), newStream.id);
      return DataSuccess(newStream.toEntity());
    } on DatabaseConnectionException catch (e) {
      return DataError(e);
    } on UserNotFoundException catch (e) {
      return DataError(e);
    } on Exception catch (e) {
      return DataError(Exception("Failed to add stream: $e"));
    }
  }

  Future<String> addRoom() async {
    var token = dotenv.env['VIDEOSDK_TOKEN']!; // Replace with your actual token
    return firebase.addRoom(token);
  }

  @override
  Future<DataState<Stream>> getStreamById(String id) async {
    try {
      var snapshot = await firebase.getStreamById(id);
      return DataSuccess(toStreamObject(snapshot.value));
    } on TypeError catch (_) {
      return DataError(ObjectException("Stream could not be accessed"));
    } on Exception catch (e) {
      return DataError(e);
    }
  }

  @override
  Future<DataState<String>> removeStreamById(String roomId) async {
    try {
      firebase.removeStreamById(roomId);
      return DataSuccess(roomId);
    } on Exception catch (e) {
      return DataError(e);
    }
  }

  @override
  Future<DataState<ProductOffer>> addProductOffer(
      String roomId,
      String name,
      String descr,
      ProductType type,
      ClothingSize size,
      SimpleColor color,
      double startPrice,
      double increase) async {
    try {
      var uuid = Uuid().v1();
      var productOffer = ProductOfferDTO(
          id: uuid,
          name: name,
          descr: descr,
          type: type,
          size: size,
          color: color,
          startPrice: startPrice,
          increase: increase,
          bidders: []);
      await firebase.addProductOffer(productOffer.toJson(), roomId, uuid);
      return DataSuccess(productOffer.toEntity());
    } on NotNullableError catch (_) {
      return DataError(ObjectException("Could not create Product"));
    } on Exception catch (e) {
      return DataError(e);
    }
  }

  @override
  Future<DataState<List<ProductOffer>>> getProductOfferById(String id) async {
    try {
      DataSnapshot snapshot = await firebase.getProductOfferById(id);
      Iterable<ProductOffer> productOffers = snapshot.children.map((e) {
        final json = convertDynamicMapToStringMap(e.value as Map);
        return ProductOfferDTO.fromJson(json).toEntity();
      });
      return DataSuccess(productOffers.toList());
    } on FormatException catch (_) {
      return DataError(ObjectException("Could not Fetch product"));
    } on TypeError catch (_) {
      return DataError(ObjectException("Could not Fetch product"));
    } on Exception catch (e) {
      return DataError(Exception("Failed to fetch productOffers: $e"));
    }
  }

  @override
  Future<DataState<String>> removeProductOfferById(String id) async {
    try {
      await firebase.removeProductOfferById(id);
      return DataSuccess(id);
    } on Exception catch (e) {
      return DataError(e);
    }
  }

  @override
  Future<DataState<String>> addBid(
      String roomId, double bid, String productId) async {
    try {
      final bidder =
          BidderDTO(id: FirebaseAuth.instance.currentUser!.uid, bid: bid);
      await firebase.addBid(bidder.toJson(), roomId, productId);
      return DataSuccess(bidder.id);
    } on FormatException catch (_) {
      return DataError(ObjectException("Could not create bid"));
    } on TypeError catch (_) {
      return DataError(ObjectException("Could not create bid"));
    } on Exception catch (e) {
      return DataError(e);
    }
  }

  @override
  Future<DataState<Bidder>> getCurrentBid(String roomId) async {
    try {
      var snapshot = await firebase.getBids(roomId);
      Iterable<Bidder> bidderList = snapshot.children.map((e) {
        return BidderDTO.fromJson(e.value as Map<String, dynamic>).toEntity();
      });
      bidderList.toList().sort((a, b) => b.bid.compareTo(a.bid));
      return DataSuccess(bidderList.first);
    } on SnapshotNotFoundException catch (_) {
      return DataError(Exception("no bidders found"));
    } on Exception catch (e) {
      return DataError(e);
    }
  }

  Future<User?> getFirebaseUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<bool> isFirebaseUserSignedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Future<AuthUser> getAWSUser() async {
    return Amplify.Auth.getCurrentUser();
  }

  Future<bool> isAWSUserSignedIn() async {
    try {
      var session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      return false;
    }
  }
}
