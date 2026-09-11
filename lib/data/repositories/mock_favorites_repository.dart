import '../../core/constants/app_constants.dart';
import 'favorites_repository.dart';

class MockFavoritesRepository implements FavoritesRepository {
  final Map<String, Set<String>> _favoritesByUser = {};

  @override
  Future<Set<String>> getFavorites(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return Set<String>.from(_favoritesByUser[userId] ?? {});
  }

  @override
  Future<Set<String>> toggleFavorite({
    required String userId,
    required String propertyId,
  }) async {
    await Future<void>.delayed(AppConstants.mockDelay);
    final set = _favoritesByUser.putIfAbsent(userId, () => <String>{});
    if (set.contains(propertyId)) {
      set.remove(propertyId);
    } else {
      set.add(propertyId);
    }
    return Set<String>.from(set);
  }

  @override
  Future<Set<String>> addFavorite({
    required String userId,
    required String propertyId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final set = _favoritesByUser.putIfAbsent(userId, () => <String>{});
    set.add(propertyId);
    return Set<String>.from(set);
  }

  @override
  Future<Set<String>> removeFavorite({
    required String userId,
    required String propertyId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final set = _favoritesByUser.putIfAbsent(userId, () => <String>{});
    set.remove(propertyId);
    return Set<String>.from(set);
  }
}
