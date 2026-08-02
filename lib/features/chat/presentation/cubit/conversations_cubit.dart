import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  final EnsureChatReadyUseCase _ensureReady;
  final WatchConversationsUseCase _watchConversations;
  StreamSubscription? _subscription;

  ConversationsCubit(this._ensureReady, this._watchConversations)
      : super(const ConversationsInitial());

  Future<void> load() async {
    emit(const ConversationsLoading());
    final result = await _ensureReady();
    final failure = result.fold((f) => f, (_) => null);
    if (failure != null) {
      emit(ConversationsError(failure.message));
      return;
    }
    await _subscription?.cancel();
    _subscription = _watchConversations().listen(
      (items) => emit(ConversationsLoaded(items)),
      onError: (_) => emit(const ConversationsError('تعذّر تحميل المحادثات')),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
