import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/teacher_external_links_usecases.dart';
import 'teacher_external_links_state.dart';

class TeacherExternalLinksCubit extends Cubit<TeacherExternalLinksState> {
  final GetTeacherExternalLinksUseCase _getLinks;
  final CreateExternalLinkUseCase _createLink;
  final UpdateExternalLinkUseCase _updateLink;
  final DeleteExternalLinkUseCase _deleteLink;
  final int classId;

  TeacherExternalLinksCubit({
    required this.classId,
    required GetTeacherExternalLinksUseCase getLinks,
    required CreateExternalLinkUseCase createLink,
    required UpdateExternalLinkUseCase updateLink,
    required DeleteExternalLinkUseCase deleteLink,
  })  : _getLinks = getLinks,
        _createLink = createLink,
        _updateLink = updateLink,
        _deleteLink = deleteLink,
        super(const TeacherExternalLinksLoading());

  Future<void> load() async {
    emit(const TeacherExternalLinksLoading());
    final result = await _getLinks(classId: classId);
    result.fold(
      (f) => emit(TeacherExternalLinksError(f.message)),
      (links) => emit(TeacherExternalLinksLoaded(links)),
    );
  }

  Future<String?> create({required int subjectId, required String url}) async {
    final result = await _createLink(classId: classId, subjectId: subjectId, url: url);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> update({required int id, required String url}) async {
    final result = await _updateLink(id: id, url: url);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }

  Future<String?> delete(int id) async {
    final result = await _deleteLink(id);
    return result.fold((f) => f.message, (_) {
      load();
      return null;
    });
  }
}
