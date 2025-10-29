import 'package:amplify_flutter/amplify_flutter.dart';
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
  const RoomPage({Key? key, required this.roomId});
  final String roomId;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late Room _room;
  late AuthUser awsUser;
  bool isOwner = false;
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
      if (isOwner) {
        endStream(_room);
      }
      if (participants.containsKey(participantId)) {
        setState(() => participants.remove(participantId));
      }
    });

    _room.on(Events.roomLeft, () {
      if (!mounted) return;
      if (isOwner) {
        endStream(_room);
      }
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
        listener: (context, state) async {
          if (state.status == StreamStatus.success &&
              state.selectedStream != null &&
              !_roomCreated) {
            _roomCreated = true;
            awsUser = await Amplify.Auth.getCurrentUser();
            ownerId = state.selectedStream!.owner;
            isOwner = ownerId == awsUser.userId;

            _room = VideoSDK.createRoom(
              roomId: widget.roomId,
              token: dotenv.env['VIDEOSDK_TOKEN']!,
              displayName:
                  "${isOwner ? "Host:" : "Viewer:"}${awsUser.username}",
              micEnabled: false,
              camEnabled: isOwner,
              participantId: awsUser.userId,
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
                          ? SizedBox(
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
                          child: Text(isOwner
                              ? "Creating Live Stream"
                              : "Joining Live Stream"),
                        )),
                ),
                joined != null
                    ? isOwner
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

  Future<void> setOwnerId() async {
    try {
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

  User getFirebaseUser() {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("ID not found");
    return user;
  }

  Future<AuthUser> getAWSUser() {
    return Amplify.Auth.getCurrentUser();
  }
}
