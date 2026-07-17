import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  final int id;
  final String title;
  final String body;
  final String? imageUrl;
  final String publishedAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [id, title, body, imageUrl, publishedAt];
}
