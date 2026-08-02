import 'package:equatable/equatable.dart';

abstract class BroadcastState extends Equatable {
  const BroadcastState();
  @override
  List<Object?> get props => [];
}

class BroadcastIdle extends BroadcastState {
  const BroadcastIdle();
}

class BroadcastSending extends BroadcastState {
  const BroadcastSending();
}

class BroadcastSuccess extends BroadcastState {
  final int sentTo;
  const BroadcastSuccess(this.sentTo);
  @override
  List<Object?> get props => [sentTo];
}

class BroadcastError extends BroadcastState {
  final String message;
  const BroadcastError(this.message);
  @override
  List<Object?> get props => [message];
}
