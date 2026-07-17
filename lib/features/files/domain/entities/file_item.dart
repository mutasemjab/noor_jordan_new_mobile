import 'package:equatable/equatable.dart';

class FileItem extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? subject;
  final String fileUrl;
  final String? year;

  const FileItem({
    required this.id,
    required this.title,
    this.description,
    this.subject,
    required this.fileUrl,
    this.year,
  });

  @override
  List<Object?> get props => [id, title, description, subject, fileUrl, year];
}
