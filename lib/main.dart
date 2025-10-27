import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:streaming/core/util/appBlocObserver.dart';
import 'package:streaming/features/auction/data/repository_impl/stream_repository_impl.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/features/auction/presentation/blocs/streamBloc.dart';
import 'package:streaming/features/auth/presentation/pages/login.dart';
import 'package:streaming/routeObserver.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  Bloc.observer = AppBlocObserver(); // 🔹 Add this line

  runApp(
    Provider<StreamRepository>(
      create: (_) => StreamRepositoryImpl(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  StreamBloc(streamRep: context.read<StreamRepository>())),
          // BlocProvider(
          //     create: (_) =>
          //         ProductBloc(streamRep: _.read<StreamRepository>())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
