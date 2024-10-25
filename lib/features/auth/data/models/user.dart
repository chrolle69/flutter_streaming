import 'package:streaming/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
  String? id,
  String? name,
  String? email,
  UserType? type,
  });

}