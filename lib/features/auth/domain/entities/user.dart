import 'package:equatable/equatable.dart';


class User extends Equatable {
  final String? id;
  final String? name;
  final String? email;
  final UserType? type;

  const User({
    this.id,
    this.name,
    this.email,
    this.type
  });

  @override
  List<Object?> get props {
    return [id, name, email, type];
  }
}

enum UserType {
  admin,
  consumer,
  seller
}