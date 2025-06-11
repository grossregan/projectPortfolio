import '../models/favorite_model.dart';

class FavoritePresenter {
  final Function(List<FavoriteModel>)
  onFavoritesLoaded; // Code adapted from suggestions by ChatGPT (OpenAI), April 2025

  FavoritePresenter({required this.onFavoritesLoaded});

  void loadFavorites() {
    FavoriteModel.getFavorites().then((favorites) {
      onFavoritesLoaded(favorites);
    });
  }

  void removeFavorite(String id, String name) {
    FavoriteModel.removeFavorite(
      id,
      name,
    ).then((_) => loadFavorites()).catchError((error) {
      // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
    });
  }

  void editFavoriteDescription(String id, String newDescription) async {
    //need to work on this
    await FavoriteModel.editFavoriteDescription(id, newDescription);
  }
}
