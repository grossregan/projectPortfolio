import 'package:flutter/material.dart';
import '../models/favorite_model.dart';
import '../presenters/favorite_presenter.dart';

class FavoriteView extends StatelessWidget {
  const FavoriteView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const FavoriteList());
  }
}

class FavoriteList extends StatefulWidget {
  const FavoriteList({super.key});
  @override
  _FavoriteListState createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {
  // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
  late FavoritePresenter _presenter;
  List<FavoriteModel> _favorites = [];
  bool _isLoading = true; // for async purpose
  @override
  void initState() {
    super.initState();
    _presenter = FavoritePresenter(
      onFavoritesLoaded: (favorites) {
        setState(() {
          _favorites =
              favorites; // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
          _isLoading = false;
        });
      },
    );
    _presenter.loadFavorites();
  }

  void _removeFavorite(id, name) {
    _presenter.removeFavorite(
      id,
      name,
    ); // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
  }

  void _editFavoriteDescription(id, String newDescription) {
    // need to work on this
    _presenter.editFavoriteDescription(id, newDescription);
  }

  void _showEditDialog(String id) {
    TextEditingController controller = TextEditingController();
    FavoriteModel favoriteToEdit = _favorites.firstWhere(
      (favorite) => favorite.id == id,
    ); // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
    controller.text = favoriteToEdit.description;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Favorite Description'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Enter new description",
            ), // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
          ),
          actions: [
            TextButton(
              onPressed: () async {
                _editFavoriteDescription(id, controller.text);
                _presenter.loadFavorites();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(); // Code adapted from suggestions by ChatGPT (OpenAI), April 2025
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [Icon(Icons.star, color: Colors.yellow, size: 28)],
        title: const Text('Exercise Favorites', style: TextStyle()),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        //foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/fitness-backround.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  var favorite = _favorites[index];
                  return Card(
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withValues(alpha: .90),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ListTile(
                      title: Text(
                        favorite.name,
                        style: const TextStyle(
                          //color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description:',
                            style: TextStyle(
                              //color: Colors.black,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            favorite.description,
                            style: const TextStyle(
                              //color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 40,
                            ),
                            onPressed:
                                () =>
                                    _removeFavorite(favorite.id, favorite.name),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit /*color: Colors.black*/,
                            ),
                            onPressed:
                                () => _showEditDialog(
                                  favorite.id,
                                ), // implement this
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}
