import 'package:flutter/material.dart';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auction/domain/entities/stream.dart';
import 'package:streaming/features/auction/data/repository/stream_repository_impl.dart';
import 'package:streaming/features/auction/domain/stream_repository.dart';
import 'package:streaming/features/auction/presentation/pages/addStreamPage.dart';
import 'package:streaming/features/auction/presentation/pages/roomPage.dart';
import 'package:streaming/routeObserver.dart';

class StreamListPage extends StatefulWidget {
  const StreamListPage({super.key});

  @override
  State<StreamListPage> createState() => _StreamListPageState();
}

class _StreamListPageState extends State<StreamListPage> with RouteAware {
  StreamRepository streamRep = StreamRepositoryImpl();
  List<Stream> data = [];

  @override
  void initState() {
    super.initState();
    fetchStreams();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Refresh data when coming back to this page
    fetchStreams();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> fetchStreams() async {
    var result = await streamRep.getStreams();
    if (result is DataSuccess) {
      setState(() {
        data = result.data;
      });
    } else {
      setState(() {
        data = [];
      });
      throw Exception(result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchStreams,
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int position) {
            return GestureDetector(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      height: 100,
                      width: 100,
                      image:
                          const AssetImage('assets/images/default_image.jpg'),
                    ),
                    Text(data[position].title),
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RoomPage(
                        roomId: data[position].id,
                        onFetchStreams: fetchStreams)));
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  AddStreamPage(onStreamAdded: fetchStreams)));
        },
      ),
    );
  }
}
