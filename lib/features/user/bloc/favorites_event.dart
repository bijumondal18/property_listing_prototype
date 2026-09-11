part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

final class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class FavoritesToggleRequested extends FavoritesEvent {
  const FavoritesToggleRequested({
    required this.userId,
    required this.propertyId,
  });

  final String userId;
  final String propertyId;

  @override
  List<Object?> get props => [userId, propertyId];
}

final class FavoritesCleared extends FavoritesEvent {
  const FavoritesCleared();
}
