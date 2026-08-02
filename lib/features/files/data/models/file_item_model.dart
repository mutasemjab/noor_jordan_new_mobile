import '../../domain/entities/file_item.dart';

class FileItemModel extends FileItem {
  const FileItemModel({
    required super.id,
    required super.title,
    super.description,
    super.subject,
    required super.fileUrl,
    super.year,
  });

  factory FileItemModel.fromJson(Map<String, dynamic> json) {
    final subjectRaw = json['subject'];
    String? subjectName;
    if (subjectRaw is Map<String, dynamic>) {
      subjectName = subjectRaw['name_ar'] as String? ??
          subjectRaw['name'] as String?;
    } else if (subjectRaw is String) {
      subjectName = subjectRaw;
    }

    return FileItemModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      subject: subjectName,
      fileUrl: json['pdf_url'] as String? ??
          json['file_url'] as String? ??
          json['file'] as String? ??
          json['url'] as String? ??
          '',
      year: json['year']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'file_url': fileUrl,
      'year': year,
    };
  }
}
