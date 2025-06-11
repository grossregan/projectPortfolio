import 'package:cs_3541_final_project/models/favorite_job_model.dart';
import 'package:cs_3541_final_project/models/job_information_model.dart';

class FavoriteJobPresenter {
  final Function(Map<String, JobData>) onFavoritesLoaded;

  FavoriteJobPresenter({required this.onFavoritesLoaded});

  void loadFavorites() {
    FavoriteJobModel.getFavorites().then((favorites) {
      onFavoritesLoaded(favorites);
    });
  }

  void removeFavorite(String id) {
    FavoriteJobModel.removeFavorite(id)
        .then((_) => loadFavorites())
        .catchError((onError) {});
  }
}

class FavoriteResourcePresenter {
  final Function(List<FavoriteResourceModel>) onFavoritesLoaded;

  FavoriteResourcePresenter({required this.onFavoritesLoaded});

  void loadFavorites() {
    FavoriteResourceModel.getFavorites().then((favorites) {
      onFavoritesLoaded(favorites);
    });
  }

  void removeFavorite(String id) {
    FavoriteResourceModel.removeFavorite(id)
        .then((_) => loadFavorites())
        .catchError((onError) {});
  }
}
