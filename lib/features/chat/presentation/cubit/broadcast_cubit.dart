import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'broadcast_state.dart';

class BroadcastCubit extends Cubit<BroadcastState> {
  final BroadcastToClassUseCase _broadcast;

  BroadcastCubit(this._broadcast) : super(const BroadcastIdle());

  Future<void> send({
    required int classId,
    String? text,
    File? mediaFile,
    ChatMessageType? mediaType,
    int? durationSeconds,
  }) async {
    emit(const BroadcastSending());
    final result = await _broadcast(
      classId: classId,
      text: text,
      mediaFile: mediaFile,
      mediaType: mediaType,
      durationSeconds: durationSeconds,
    );
    result.fold(
      (failure) => emit(BroadcastError(failure.message)),
      (count) => emit(BroadcastSuccess(count)),
    );
  }
}
