class ChatUid {
  ChatUid._();

  static String student(int id) => 'student_$id';
  static String teacher(int id) => 'teacher_$id';

  /// Deterministic conversation id between one teacher and one student —
  /// must match the convention the backend uses for broadcast fan-out.
  static String conversationId({required int teacherId, required int studentId}) =>
      'teacher_${teacherId}_student_$studentId';
}
