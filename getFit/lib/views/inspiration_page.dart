import 'package:agile_avengers_get_fit/models/inspiration_model.dart';
import 'package:agile_avengers_get_fit/views/common_app_bar.dart';
import 'package:agile_avengers_get_fit/views/common_scaffold.dart';
import 'package:agile_avengers_get_fit/views/inspiration_favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

// https://inspirobot.me/api?generate=true
class InspirationPage extends StatefulWidget {
  const InspirationPage({super.key});

  @override
  State<InspirationPage> createState() => InspirationPageState();
}

class InspirationPageState extends State<InspirationPage> {
  String? _imageUrl;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadInspiration();
  }

  Future<void> loadInspiration() async {
    String inspiration = await InspirationModel.getInspiration();
    setState(() {
      _imageUrl = inspiration;
      _isFavorite = false;
    });
  }

  Future<void> setInspiration(String inspiration) async {
    setState(() {
      _imageUrl = inspiration;
      _isFavorite = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'Inspiration',
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            tooltip: 'Favorite inspirations',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => InspirationFavoritesPage(
                          setInspiration: setInspiration,
                        ),
                  ),
                ),
          ),
        ],
      ),
      body: Center(
        child:
            _imageUrl == null
                ? CircularProgressIndicator()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(_imageUrl!),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          label: Text(_isFavorite ? "Unfavorite" : "Favorite"),
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          onPressed: () async {
                            if (_isFavorite) {
                              await InspirationModel.removeFavorite(_imageUrl!);
                            } else {
                              await InspirationModel.addFavorite(_imageUrl!);
                            }
                            setState(() => _isFavorite = !_isFavorite);
                          },
                        ),
                        SizedBox(width: 20),
                        ElevatedButton.icon(
                          label: Text("Generate"),
                          icon: Icon(Icons.refresh),
                          onPressed: loadInspiration,
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      label: Text("Share"),
                      icon: Icon(Icons.share),
                      onPressed:
                          () => Share.share(
                            _imageUrl!,
                            subject: 'Inspiration', // for email i guess
                            sharePositionOrigin: Rect.fromLTWH(0, 0, 0, 0),
                          ),
                    ),
                  ],
                ),
      ),
    );
  }
}
