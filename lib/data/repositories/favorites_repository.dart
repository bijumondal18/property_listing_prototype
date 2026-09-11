abstract class FavoritesRepository {
  Future<Set<String>> getFavorites(String userId);

  Future<Set<String>> toggleFavorite({
    required String userId,
    required String propertyId,
  });

  Future<Set<String>> addFavorite({
    required String userId,
    required String propertyId,
  });

  Future<Set<String>> removeFavorite({
    required String userId,
    required String propertyId,
  });
}
