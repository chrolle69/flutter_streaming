import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/features/auction/presentation/blocs/streamBloc.dart';
import 'package:streaming/features/auction/presentation/blocs/streamEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/streamState.dart';
import 'package:streaming/features/auction/presentation/pages/roomPage.dart';
import 'package:streaming/features/auction/presentation/widgets/addStreamForm.dart';

class AddStreamPage extends StatelessWidget {
  const AddStreamPage({super.key, required this.onStreamAdded});
  final Function onStreamAdded;

  @override
  Widget build(BuildContext context) {
    return BlocListener<StreamBloc, StreamState>(
      listenWhen: (previous, current) {
        // Only listen if selectedStream changes to non-null
        return previous.selectedStream != current.selectedStream &&
            current.selectedStream != null;
      },
      listener: (context, state) {
        final stream = state.selectedStream!;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RoomPage(
            roomId: stream.id,
          ),
        ));
      },
      child: Scaffold(
        body: AddStreamForm(),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "fab1",
              child: Icon(Icons.arrow_back),
              onPressed: () {
                onStreamAdded();
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 5),
            FloatingActionButton(
              heroTag: "fab2",
              child: Icon(Icons.add),
              onPressed: () {
                context.read<StreamBloc>().add(AddStreamEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
