import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_external_links_usecase.dart';
import 'external_links_state.dart';

class ExternalLinksCubit extends Cubit<ExternalLinksState> {
  final GetExternalLinksUseCase _useCase;
  ExternalLinksCubit(this._useCase) : super(const ExternalLinksLoading());

  Future<void> load() async {
    emit(const ExternalLinksLoading());
    final result = await _useCase();
    result.fold(
      (f) => emit(ExternalLinksError(f.message)),
      (links) => emit(ExternalLinksLoaded(links)),
    );
  }
}
