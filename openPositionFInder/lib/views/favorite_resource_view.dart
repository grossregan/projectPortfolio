import 'package:cs_3541_final_project/models/favorite_job_model.dart';
import 'package:flutter/material.dart';
import '../presenters/favorite_presenter.dart';

class FavoriteResourceView extends StatelessWidget {
  const FavoriteResourceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FavoriteResourceList(),
    );
  }
}

class FavoriteResourceList extends StatefulWidget {
  const FavoriteResourceList({super.key});

  @override
  State<FavoriteResourceList> createState() => _FavoriteResourceItem();
}

class _FavoriteResourceItem extends State<FavoriteResourceList> {
  late FavoriteResourcePresenter _favoritePresenter;
  List<FavoriteResourceModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _favoritePresenter =
        FavoriteResourcePresenter(onFavoritesLoaded: (favorites) {
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    });
    _favoritePresenter.loadFavorites();
  }

  void _removeFavorite(id) {
    _favoritePresenter.removeFavorite(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Favorite Resources'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _favorites.isEmpty ?
        const Center(
          child: Text(
            style: TextStyle(fontSize: 16),
            'No favorite resources found'),
        )
      : (_isLoading) ?
        const Center(
          child: CircularProgressIndicator(),
        )
      : ListView.builder(
          itemCount: _favorites.length,
          itemBuilder: (BuildContext context, int index) {
            final favorite = _favorites[index];
            return Card(
              child: ListTile(
                title: Text(favorite.resourceName),
              ),
            );
          }),
    );
  }
}
