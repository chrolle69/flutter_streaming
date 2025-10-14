import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/home/data/models/stream.dart';
import 'package:streaming/features/home/data/repository/stream_repository_impl.dart';
import 'package:streaming/features/home/domain/stream_repository.dart';
import 'package:streaming/features/home/presentation/widgets/OwnerPanel.dart';
import 'package:streaming/features/home/presentation/widgets/ViewerPanel.dart';
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
                      ? OwnerPanel(roomId: widget.roomId)
                      : ViewerPanel(roomId: widget.roomId)
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

User getUser() {
  var user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("ID not found");
  return user;
}
