import 'dart:js_interop';
import 'package:streaming/core/resources/data_state.dart';
import 'package:streaming/features/auth/domain/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserRepositoryImpl implements UserRepository {
  @override
  DataState getUser() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return DataSuccess(user);
    }
    return DataError(NullRejectionException(true));
  }

}