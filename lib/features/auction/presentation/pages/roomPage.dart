import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/features/auction/domain/entities/stream.dart';
import 'package:streaming/features/auction/presentation/blocs/streamBloc.dart';
import 'package:streaming/features/auction/presentation/blocs/streamEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/streamState.dart';
import 'package:streaming/features/auction/presentation/widgets/OwnerPanel.dart';
import 'package:streaming/features/auction/presentation/widgets/ViewerPanel.dart';
import 'package:streaming/features/auction/presentation/widgets/participanTile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:videosdk/videosdk.dart' hide Stream;

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
  bool _roomCreated = false;

  @override
  void initState() {
    super.initState();
    context.read<StreamBloc>().add(FetchStreamByIdEvent(roomId: widget.roomId));
    context
        .read<StreamBloc>()
        .add(CheckStreamAvailableEvent(roomId: widget.roomId));
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
      if (!mounted) return;
      if (isOwner(getUser().uid)) {
        endStream(_room);
      }
      widget.onFetchStreams();
      participants.clear();
      popPage();
    });
  }

  void popPage() {
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        _room.leave();
      },
      child: BlocListener<StreamBloc, StreamState>(
        listener: (context, state) {
          if (state.status == StreamStatus.success &&
              state.selectedStream != null &&
              !_roomCreated) {
            _roomCreated = true;
            ownerId = state.selectedStream!.owner;
            bool amOwner = ownerId == getUser().uid;

            _room = VideoSDK.createRoom(
              roomId: widget.roomId,
              token: dotenv.env['VIDEOSDK_TOKEN']!,
              displayName: amOwner
                  ? "Host: ${getUser().displayName ?? "Anonymous"}"
                  : "Viewer: ${getUser().displayName ?? "Anonymous"}",
              micEnabled: false,
              camEnabled: amOwner,
              participantId: getUser().uid,
              defaultCameraIndex: 1,
            );

            setRoomEventListener();
            _room.join();
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text("VideoSDK QuickStart")),
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
      ),
    );
  }

  bool isOwner(String userId) {
    return ownerId != null && userId == ownerId;
  }

  Future<void> setOwnerId() async {
    try {
      print(widget.roomId);
      var stream = context.read<StreamBloc>().state.selectedStream!;
      print("Fetched stream owner: ${stream.owner}");
      setState(() {
        ownerId = stream.owner;
      });
    } catch (e) {
      print("Error setting ownerId: $e");
    }
  }

  void endStream(Room room) {
    context
        .read<StreamBloc>()
        .add(RemoveStreamByIdEvent(roomId: widget.roomId));
    for (Participant par in participants.values) {
      par.remove();
    }
    room.end();
  }

  Future<String?> getOwnerId() async {
    try {
      Stream stream = context.read<StreamBloc>().state.selectedStream!;
      return stream.owner; // return it directly
    } catch (e) {
      print("Error fetching ownerId: $e");
      return null;
    }
  }

  User getUser() {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("ID not found");
    return user;
  }
}
