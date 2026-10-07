import 'package:equatable/equatable.dart';
import '../../domain/entities/external_link.dart';

abstract class ExternalLinksState extends Equatable {
  const ExternalLinksState();
  @override
  List<Object?> get props => [];
}

class ExternalLinksLoading extends ExternalLinksState {
  const ExternalLinksLoading();
}

class ExternalLinksLoaded extends ExternalLinksState {
  final List<ExternalLink> links;
  const ExternalLinksLoaded(this.links);
  @override
  List<Object?> get props => [links];
}

class ExternalLinksError extends ExternalLinksState {
  final String message;
  const ExternalLinksError(this.message);
  @override
  List<Object?> get props => [message];
}
