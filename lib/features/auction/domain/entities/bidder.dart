import 'package:equatable/equatable.dart';

class Bidder extends Equatable {
  final String id;
  final double bid;

  const Bidder({
    required this.id,
    required this.bid,
  });

  @override
  List<Object?> get props {
    return [id, bid];
  }
}
