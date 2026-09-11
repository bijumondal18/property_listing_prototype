part of 'favorites_bloc.dart';

enum FavoritesStatus { initial, loading, ready }

final class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favoriteIds = const {},
    this.userId,
    this.lastMessage,
  });

  final FavoritesStatus status;
  final Set<String> favoriteIds;
  final String? userId;
  final String? lastMessage;

  bool isFavorite(String propertyId) => favoriteIds.contains(propertyId);

  FavoritesState copyWith({
    FavoritesStatus? status,
    Set<String>? favoriteIds,
    String? userId,
    String? lastMessage,
    bool clearMessage = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      userId: userId ?? this.userId,
      lastMessage: clearMessage ? null : (lastMessage ?? this.lastMessage),
    );
  }

  @override
  List<Object?> get props => [status, favoriteIds, userId, lastMessage];
}
