import 'package:agile_avengers_get_fit/models/inspiration_model.dart';
import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/common_scaffold.dart';
import 'package:agile_avengers_get_fit/views/common_snackbar.dart';
import 'package:flutter/material.dart';

class InspirationFavoritesPage extends StatefulWidget {
  final void Function(String inspiration) setInspiration;

  const InspirationFavoritesPage({super.key, required this.setInspiration});

  @override
  State<InspirationFavoritesPage> createState() =>
      _InspirationFavoritesPageState();
}

class _InspirationFavoritesPageState extends State<InspirationFavoritesPage> {
  Map<String, DateTime> favoriteInspirations = {};
  int _density = 3;

  @override
  void initState() {
    super.initState();
    loadFavoriteInspirations();
  }

  void loadFavoriteInspirations() async {
    await InspirationModel.getFavorites().then(
      (favorites) => setState(() => favoriteInspirations = favorites),
    );
  }

  void removeFavoriteInspiration(String inspiration) async {
    if (!favoriteInspirations.containsKey(inspiration)) return;
    setState(() => favoriteInspirations.remove(inspiration));
    final removedAt = InspirationModel.removeFavorite(inspiration);

    if (mounted) {
      CommonSnackBar(
        text: 'Inspiration removed',
        theme: Theme.of(context),
        onUndoPressed: () async {
          final rmAt = await removedAt;
          InspirationModel.addFavorite(inspiration, addedAt: rmAt).then(
            (_) => setState(() => favoriteInspirations[inspiration] = rmAt),
          );
          if (mounted) {
            CommonSnackBar(
              text: 'Inspiration restored',
              theme: Theme.of(context),
            ).show(context);
          }
        },
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = favoriteInspirations.entries.toList();
    favorites.sort((a, b) => a.value.compareTo(b.value));
    final min = 1, max = 5;
    showDensitySlider() => showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          child: StatefulBuilder(
            builder:
                (context, setStateInner) => Column(
                  children: [
                    Text('Row Density'),
                    Row(
                      children: [
                        Text(min.toString()),
                        Slider(
                          min: min.toDouble(),
                          max: max.toDouble(),
                          divisions: max - min,
                          value: _density.toDouble(),
                          label: _density.toString(),
                          onChanged:
                              (value) => setState(
                                () => setStateInner(
                                  () => _density = value.toInt(),
                                ),
                              ),
                          onChangeEnd: (val) => Navigator.pop(context),
                        ),
                        Text(max.toString()),
                      ],
                    ),
                  ],
                ),
          ),
        ),
      ],
    );

    return CommonScaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'Favorite Inspirations',
        actions: [
          IconButton(
            icon: Icon(Icons.grid_view_rounded),
            onPressed: showDensitySlider,
          ),
        ],
      ),
      body:
          favoriteInspirations.isEmpty
              ? Center(
                child: Text(
                  'No favorite inspirations',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              )
              : GridView.count(
                crossAxisCount: _density,
                children: [
                  for (final inspiration in favorites)
                    Dismissible(
                      key: Key(inspiration.key),
                      onDismissed: (direction) {
                        removeFavoriteInspiration(inspiration.key);
                      },
                      child: GestureDetector(
                        onTap: () {
                          widget.setInspiration(inspiration.key);
                          Navigator.pop(context);
                        },
                        child: Card(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Stack(
                              children: [
                                Image.network(inspiration.key),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap:
                                        () => removeFavoriteInspiration(
                                          inspiration.key,
                                        ),
                                    child: Icon(Icons.close, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }
}
