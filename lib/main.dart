import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:streaming/core/util/appBlocObserver.dart';
import 'package:streaming/features/auction/data/data_sources/remote/remote_data_source_aws.dart';
import 'package:streaming/features/auction/data/data_sources/remote/remote_data_source_firebase.dart';
import 'package:streaming/features/auction/data/repository_impl/stream_repository_impl.dart';
import 'package:streaming/features/auction/domain/repository/stream_repository.dart';
import 'package:streaming/features/auction/presentation/blocs/streamBloc.dart';
import 'package:streaming/features/auction/presentation/blocs/productBloc.dart';
import 'package:streaming/features/auth/presentation/pages/login.dart';
import 'package:streaming/routeObserver.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
// Amplify Flutter Packages
import 'amplifyconfiguration.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  Bloc.observer = AppBlocObserver(); // 🔹 Add this line
  _configureAmplify();

  var firebaseDatabase = FirebaseDatabase.instance.ref();

  runApp(
    Provider<StreamRepository>(
      create: (_) => StreamRepositoryImpl(
          RemoteDataSourceFirebase(db: firebaseDatabase),
          RemoteDataSourceAWS(db: firebaseDatabase)),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  StreamBloc(streamRep: context.read<StreamRepository>())),
          BlocProvider(
              create: (context) =>
                  ProductBloc(streamRep: context.read<StreamRepository>())),
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
    return Authenticator(
        child: MaterialApp(
      builder: Authenticator.builder(),
      title: 'Flutter Demo',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Login(),
    ));
  }
}

Future<void> _configureAmplify() async {
  // Add any Amplify plugins you want to use
  final authPlugin = AmplifyAuthCognito();
  await Amplify.addPlugin(authPlugin);

  // You can use addPlugins if you are going to be adding multiple plugins
  // await Amplify.addPlugins([authPlugin, analyticsPlugin]);

  // Once Plugins are added, configure Amplify
  // Note: Amplify can only be configured once.
  try {
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on AmplifyAlreadyConfiguredException {
    safePrint(
        "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
  }
}
