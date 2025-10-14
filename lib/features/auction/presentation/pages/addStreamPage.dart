import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/data/models/stream.dart';
import 'package:streaming/features/auction/presentation/blocs/addStreamState.dart';
import 'package:streaming/features/auction/presentation/pages/roomPage.dart';
import 'package:streaming/features/auction/presentation/widgets/addStreamForm.dart';

class AddStreamPage extends StatelessWidget {
  const AddStreamPage({super.key, required this.onStreamAdded});
  final Function onStreamAdded;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => AddStreamState(),
      child: AddStreamPageHelper(
        onStreamAdded: onStreamAdded,
      ),
    );
  }
}

//used so that the provider is initialzed before it is used
class AddStreamPageHelper extends StatelessWidget {
  const AddStreamPageHelper({super.key, required this.onStreamAdded});
  final Function onStreamAdded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AddStreamForm(),
      floatingActionButton: Builder(
        builder: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "fab1",
              child: Icon(Icons.arrow_back),
              onPressed: () {
                print("going back");
                onStreamAdded();
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 5),
            FloatingActionButton(
              heroTag: "fab2",
              child: Icon(Icons.add),
              onPressed: () async {
                final navigator = Navigator.of(context);
                var dataState =
                    await Provider.of<AddStreamState>(context, listen: false)
                        .addStream();
                print("going back");
                if (dataState is DataSuccess) {
                  if (dataState.data is StreamModel) {
                    var stream = dataState.data as StreamModel;
                    navigator.push(MaterialPageRoute(
                        builder: (context) => RoomPage(
                            roomId: stream.id, onFetchStreams: onStreamAdded)));
                  }
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
