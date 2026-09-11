import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/favorites_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc({required this._favoritesRepository})
      : super(const FavoritesState()) {
    on<FavoritesLoadRequested>(_onLoad);
    on<FavoritesToggleRequested>(_onToggle);
    on<FavoritesCleared>(_onCleared);
  }

  final FavoritesRepository _favoritesRepository;

  Future<void> _onLoad(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(userId: event.userId, status: FavoritesStatus.loading));
    try {
      final ids = await _favoritesRepository.getFavorites(event.userId);
      emit(
        state.copyWith(
          status: FavoritesStatus.ready,
          favoriteIds: ids,
          userId: event.userId,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: FavoritesStatus.ready,
          favoriteIds: const {},
        ),
      );
    }
  }

  Future<void> _onToggle(
    FavoritesToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final previous = Set<String>.from(state.favoriteIds);
    final wasFavorite = previous.contains(event.propertyId);
    final optimistic = Set<String>.from(previous);
    if (wasFavorite) {
      optimistic.remove(event.propertyId);
    } else {
      optimistic.add(event.propertyId);
    }
    emit(
      state.copyWith(
        favoriteIds: optimistic,
        lastMessage: wasFavorite
            ? 'Property removed from saved properties!'
            : 'Property saved!',
      ),
    );
    try {
      final ids = await _favoritesRepository.toggleFavorite(
        userId: event.userId,
        propertyId: event.propertyId,
      );
      emit(state.copyWith(favoriteIds: ids, userId: event.userId));
    } catch (_) {
      emit(
        state.copyWith(
          favoriteIds: previous,
          lastMessage: 'Could not update favorites. Please try again.',
        ),
      );
    }
  }

  void _onCleared(FavoritesCleared event, Emitter<FavoritesState> emit) {
    emit(const FavoritesState());
  }
}
