import 'package:equatable/equatable.dart';
import '../../domain/entities/announcement.dart';

abstract class AnnouncementsState extends Equatable {
  const AnnouncementsState();
  @override
  List<Object?> get props => [];
}

class AnnouncementsInitial extends AnnouncementsState {}
class AnnouncementsLoading extends AnnouncementsState {}

class AnnouncementsLoaded extends AnnouncementsState {
  final List<Announcement> items;
  final bool hasMore;
  final int currentPage;
  const AnnouncementsLoaded(this.items, {this.hasMore = false, this.currentPage = 1});
  @override
  List<Object?> get props => [items, hasMore, currentPage];
}

class AnnouncementsLoadingMore extends AnnouncementsLoaded {
  const AnnouncementsLoadingMore(super.items, {super.hasMore, super.currentPage});
}

class AnnouncementsError extends AnnouncementsState {
  final String message;
  const AnnouncementsError(this.message);
  @override
  List<Object?> get props => [message];
}
