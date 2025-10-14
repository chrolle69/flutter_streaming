// import 'package:flutter/material.dart';
// import 'package:streaming/features/home/data/repository/stream_repository_impl.dart';
// import 'package:streaming/features/home/domain/entities/stream.dart';
// import 'package:streaming/features/home/domain/stream_repository.dart';

// class AddStreamState extends ChangeNotifier {
//     StreamRepository streamRep = StreamRepositoryImpl();
//     var highest = (id: "", bid: 0);

//     String getHighestId() {
//       return highest.id;
//     }
//     int getHighestBid() {
//       return highest.bid;
//     }
    
//     void addBid(String userId, int bid) {
//       bidders[userId] = bid;
//       for (String key in bidders.keys){
//         if (bidders[key] !> highest.bid) {
//           highest = MapEntry(key, bidders[key]) as ({int bid, String id});
//         }
//       }
//       notifyListeners();
//     }

// }