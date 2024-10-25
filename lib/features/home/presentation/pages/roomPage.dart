import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/home/data/models/bidderDTO.dart';
import 'package:streaming/features/home/data/models/productOfferDTO.dart';
import 'package:streaming/features/home/data/models/stream.dart';
import 'package:streaming/features/home/data/repository/stream_repository_impl.dart';
import 'package:streaming/features/home/domain/entities/stream.dart';
import 'package:streaming/features/home/domain/stream_repository.dart';
import 'package:streaming/features/home/presentation/widgets/participanTile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:videosdk/videosdk.dart';

class RoomPage extends StatefulWidget {
  const RoomPage(
      {Key? key, required this.roomId, required this.onFetchStreams});
  final String roomId;
  final Function onFetchStreams;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late Room _room;
  String? ownerId;
  String? joined;
  Map<String, Participant> participants = {};
  StreamRepository streamRep = StreamRepositoryImpl();

  @override
  void initState() {
    super.initState();
    createRoom();
  }

  void setRoomEventListener() {
    _room.on(Events.roomJoined, () {
      setState(() {
        joined = "JOINED";
        participants.putIfAbsent(
            _room.localParticipant.id, () => _room.localParticipant);
      });
    });

    _room.on(Events.participantJoined, (Participant participant) {
      print(participant.id);
      setState(
          () => participants.putIfAbsent(participant.id, () => participant));
    });

    _room.on(Events.participantLeft, (String participantId) {
      if (isOwner(participantId)) {
        endStream(_room);
      }
      if (participants.containsKey(participantId)) {
        setState(() => participants.remove(participantId));
      }
    });

    _room.on(Events.roomLeft, () {
      if (isOwner(getUser().uid)) {
        endStream(_room);
      }
      widget.onFetchStreams();
      participants.clear();
      popPage();
    });
  }

  void popPage() {
    Navigator.pop(context);
  }

  void _onWillPop(bool? b) async {
    _room.leave();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('VideoSDK QuickStart'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: joined != null
                    ? joined == "JOINED"
                        ? Container(
                            height: MediaQuery.of(context).size.height * 0.80,
                            child: ParticipantTile(
                                participant: participants.values.firstWhere(
                                    (participant) =>
                                        participant.id == ownerId)),
                          )
                        : const Text("JOINING the Room",
                            style: TextStyle(color: Colors.white))
                    : Card(
                        child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(isOwner(getUser().uid)
                            ? "Creating Live Stream"
                            : "Joining Live Stream"),
                      )),
              ),
              joined != null
                  ? isOwner(getUser().uid)
                      ? OwnerPanel(
                          roomId: widget.roomId,
                          streamRep: streamRep,
                        )
                      : ViewerPanel(
                          roomId: widget.roomId,
                          betIncrease: 10,
                          streamRep: streamRep)
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  bool isOwner(String userId) {
    return ownerId != null && userId == ownerId;
  }

  Future<void> setOwnerId() async {
    try {
      StreamModel streamModel = await getStreamById(widget.roomId);
      setState(() {
        ownerId = streamModel.owner;
      });
    } catch (e) {
      print("Error setting ownerId: $e");
    }
  }

  Future<StreamModel> getStreamById(String roomId) async {
    var dataState = await streamRep.getStreamById(roomId);
    if (dataState is DataSuccess) {
      return dataState.data;
    } else {
      throw Exception("Data failure while fetching stream");
    }
  }

  void endStream(Room room) {
    print("Ending stream");
    streamRep.removeStreamById(room.id);
    for (Participant par in participants.values) {
      print("removing: ${par.id}");
      par.remove();
    }
    room.end();
  }

  void createRoom() async {
    try {
      await checkStreamAvailable(widget.roomId);
      await setOwnerId();
      await dotenv.load(fileName: ".env");
      var firebaseUser = getUser();
      print("Checking if owner");
      print(isOwner(firebaseUser.uid));
      if (isOwner(firebaseUser.uid)) {
        print("Is owner");
        _room = VideoSDK.createRoom(
          roomId: widget.roomId,
          token: dotenv.env['VIDEOSDK_TOKEN']!,
          displayName: "Host: ${firebaseUser.displayName ?? "Anonymous"}",
          micEnabled: false,
          camEnabled: true,
          participantId: firebaseUser.uid,
          defaultCameraIndex: 1,
        );
        print("Room created");
      } else {
        print("Is viewer");
        _room = VideoSDK.createRoom(
          roomId: widget.roomId,
          token: dotenv.env['VIDEOSDK_TOKEN']!,
          displayName: "Viewer: ${firebaseUser.displayName ?? "Anonymous"}",
          micEnabled: false,
          camEnabled: false,
          participantId: firebaseUser.uid,
          defaultCameraIndex: 1,
        );
      }
    } catch (e) {
      print("No account");
      _room = VideoSDK.createRoom(
        roomId: widget.roomId,
        token: dotenv.env['VIDEOSDK_TOKEN']!,
        displayName: "No account",
        micEnabled: false,
        camEnabled: false,
        defaultCameraIndex: 1,
      );
    }
    setRoomEventListener();
    _room.join();
  }

  checkStreamAvailable(String roomId) async {
    try {
      await getStreamById(roomId);
    } catch (e) {
      print("Stream not available");
      popPage();
    }
  }
}

class ViewerPanel extends StatefulWidget {
  const ViewerPanel({
    super.key,
    required this.roomId,
    required this.betIncrease,
    required this.streamRep,
  });
  final String roomId;
  final double betIncrease;
  final StreamRepository streamRep;

  @override
  State<ViewerPanel> createState() => _ViewerPanelState();
}

class _ViewerPanelState extends State<ViewerPanel> {
  late StreamRepository streamRep;
  late DatabaseReference liveStreamRef;
  List<ProductOfferDTO> productList = [];
  BidderDTO? currentBidder;

  @override
  void initState() {
    super.initState();
    streamRep = widget.streamRep;

    liveStreamRef = FirebaseDatabase.instance
        .ref('liveStreams/${widget.roomId}/productOffers');

    liveStreamRef.onChildAdded.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print(data is Map<dynamic, dynamic>);
      setState(() {
        var product = ProductOfferDTO.fromJson(data as Map<dynamic, dynamic>);
        productList.add(product);
      });
      print(productList.first);
    });

    liveStreamRef.onChildChanged.listen((event) {
      final data = event.snapshot.value;
      print("^^^^^^^^^^^^^^^^^^^child changes");
      var tmp = data as Map<dynamic, dynamic>;
      setState(() {
        print("testing::  " + tmp['bidders'].toString());
        var newP = ProductOfferDTO.fromJson(data as Map<dynamic, dynamic>);
        var currentP = productList.firstWhere((p) => p.id == newP.id);
        int i = productList.indexOf(currentP);
        if (i != -1) {
          productList[i] = newP;
        } else {
          productList.add(newP);
        }
        print(productList.toString());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Expanded(
            child: FloatingActionButton(
              child: Text("Show Products"),
              onPressed: () {
                showBottomSheetViewer(context);
              },
            ),
          ),
        )
      ]),
    );
  }

  Future<void> showBottomSheetViewer(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
            height: 500,
            width: MediaQuery.of(context).size.width * 1,
            child: productList.isEmpty
                ? Center(child: Text("No Products Added"))
                : ListView.builder(
                    itemCount: productList.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProductRowItemViewer(
                          prod: productList[i],
                          roomId: widget.roomId,
                          streamRep: widget.streamRep,
                        ),
                      );
                    }));
      },
    );
  }
}

class OwnerPanel extends StatefulWidget {
  const OwnerPanel({super.key, required this.roomId, required this.streamRep});
  final String roomId;
  final StreamRepository streamRep;
  @override
  State<OwnerPanel> createState() => _OwnerPanelState();
}

class _OwnerPanelState extends State<OwnerPanel> {
  List<ProductOfferDTO> productList = [];
  BidderDTO? currentBidder;
  late DatabaseReference liveStreamRef;

  @override
  void initState() {
    super.initState();

    liveStreamRef = FirebaseDatabase.instance
        .ref('liveStreams/${widget.roomId}/productOffers');

    liveStreamRef.onChildAdded.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        var product = ProductOfferDTO.fromJson(data as Map<dynamic, dynamic>);
        productList.add(product);
      });
      print(productList.first);
    });

    liveStreamRef.onChildChanged.listen((event) {
      final data = event.snapshot.value;
      setState(() {
        var newP = ProductOfferDTO.fromJson(data as Map<dynamic, dynamic>);
        var currentP = productList.firstWhere((p) => p.id == newP.id);
        int i = productList.indexOf(currentP);
        if (i != -1) {
          productList[i] = newP;
        } else {
          productList.add(newP);
        }
      });
    });
  }

  void addProductOffer() {}

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: FloatingActionButton(
                  child: Text("Add Product"),
                  onPressed: () =>
                      _dialogBuilder(context, widget.streamRep, widget.roomId)),
            ),
            Expanded(
              child: FloatingActionButton(
                child: Text("Show Products"),
                onPressed: () {
                  showBottomSheetOwner(context);
                },
              ),
            ),
          ]),
    );
  }

  Future<void> showBottomSheetOwner(BuildContext context) async {
    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
            height: 500,
            width: MediaQuery.of(context).size.width * 1,
            child: productList.isEmpty
                ? Center(child: Text("No Products Added"))
                : ListView.builder(
                    itemCount: productList.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProductRowItemOwner(prod: productList[i]),
                      );
                    }));
      },
    );
  }
}

class ProductRowItemOwner extends StatelessWidget {
  const ProductRowItemOwner({
    super.key,
    required this.prod,
  });

  final ProductOfferDTO prod;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text("${prod.name}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ]),
        Text("Higest bid:"),
        Text(
          prod.highestBidder() == null
              ? "no bids"
              : "${prod.highestBidder()!.bid}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        ElevatedButton(
            onPressed: () => print("do sometinh"), child: Text("does nothing"))
      ]),
    );
  }
}

class ProductRowItemViewer extends StatelessWidget {
  const ProductRowItemViewer(
      {super.key,
      required this.prod,
      required this.roomId,
      required this.streamRep});

  final ProductOfferDTO prod;
  final String roomId;
  final StreamRepository streamRep;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text("${prod.name}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              )),
        ]),
        Text("Higest bid:"),
        Text(
          prod.highestBidder() == null
              ? "no bids"
              : "${prod.highestBidder()!.bid}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        BidButton(
          prod: prod,
          roomId: roomId,
          streamRep: streamRep,
        )
      ]),
    );
  }
}

class BidButton extends StatefulWidget {
  const BidButton({
    super.key,
    required this.prod,
    required this.roomId,
    required this.streamRep,
  });

  final ProductOfferDTO prod;
  final String roomId;
  final StreamRepository streamRep;

  @override
  State<BidButton> createState() => _BidButtonState();
}

class _BidButtonState extends State<BidButton> {
  @override
  Widget build(BuildContext context) {
    BidderDTO? currentBidder = widget.prod.highestBidder();
    if (currentBidder == null) {
      print("******************currentbidder is null");
    } else {
      print("--------${currentBidder.bid}");
    }

    return ElevatedButton(
      child: Text(
          "bid ${currentBidder == null ? widget.prod.startPrice : widget.prod.increase + currentBidder.bid},-"),
      onPressed: () {
        var bet = currentBidder == null
            ? widget.prod.startPrice
            : widget.prod.increase + currentBidder.bid;
        setState(() {
          widget.streamRep
              .addBid(getUser().uid, widget.roomId, bet, widget.prod.name);
        });
      },
    );
  }
}

Future<void> _dialogBuilder(
    BuildContext context, StreamRepository streamRep, String roomId) {
  String productName = "";
  double startPrice = 0;
  double increase = 0;
  ProductType productType = ProductType.other;

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('New Product'),
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (String str) {
                  productName = str;
                  print(productName);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    labelText: "Start Price",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (String str) {
                    startPrice = double.parse(str);
                    print(startPrice);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp("[0-9]+.?[0-9]?"))
                  ],
                  decoration: InputDecoration(
                    labelText: "Price Increment",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (String str) {
                    increase = double.parse(str);
                    print(increase);
                  }),
            )
          ],
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Confirm'),
            onPressed: () {
              try {
                streamRep.addProductOffer(
                    roomId, productName, productType, startPrice, increase);
              } catch (e) {
                print("Error: $e");
                return;
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

User getUser() {
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("ID not found");
  return user;
}
