import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streaming/features/auction/presentation/blocs/streamBloc.dart';
import 'package:streaming/features/auction/presentation/blocs/streamEvent.dart';
import 'package:streaming/features/auction/presentation/blocs/streamState.dart';
import 'package:streaming/features/auction/presentation/pages/addStreamPage.dart';
import 'package:streaming/features/auction/presentation/pages/roomPage.dart';
import 'package:streaming/routeObserver.dart';

class StreamListPage extends StatefulWidget {
  const StreamListPage({super.key});

  @override
  State<StreamListPage> createState() => _StreamListPageState();
}

class _StreamListPageState extends State<StreamListPage> with RouteAware {
  @override
  void initState() {
    super.initState();
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
    context.read<StreamBloc>().add(FetchStreamsEvent());
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamBloc = context.read<StreamBloc>();

    return BlocListener<StreamBloc, StreamState>(
      listener: (context, state) {
        // Show errors with SnackBar if needed
        if (state.status == StreamStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Live Streams")),
        body: BlocBuilder<StreamBloc, StreamState>(
          builder: (context, state) {
            if (state.status == StreamStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.streams.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => streamBloc.add(FetchStreamsEvent()),
                child: ListView(
                  children: const [
                    SizedBox(height: 200),
                    Center(child: Text("No streams available")),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => streamBloc.add(FetchStreamsEvent()),
              child: ListView.builder(
                itemCount: state.streams.length,
                itemBuilder: (context, idx) {
                  final stream = state.streams[idx];
                  return GestureDetector(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image(
                            height: 100,
                            width: 100,
                            image: const AssetImage(
                                'assets/images/default_image.jpg'),
                          ),
                          Text(stream.title),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => RoomPage(
                                roomId: stream.id,
                                onFetchStreams: () =>
                                    streamBloc.add(FetchStreamsEvent()),
                              )));
                    },
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddStreamPage(onStreamAdded: () {
                      streamBloc.add(FetchStreamsEvent());
                    })));
          },
        ),
      ),
    );
  }
}
