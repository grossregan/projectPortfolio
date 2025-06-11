import 'package:cs_3541_final_project/models/job_information_model.dart';
import 'package:cs_3541_final_project/presenters/favorite_presenter.dart';
import 'package:cs_3541_final_project/views/common_app_bar.dart';
import 'package:flutter/material.dart';

class FavoriteJobView extends StatelessWidget {
  const FavoriteJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FavoriteJobList(),
    );
  }
}

class FavoriteJobList extends StatefulWidget {
  const FavoriteJobList({super.key});

  @override
  State<FavoriteJobList> createState() => _FavoriteJobState();
}

class _FavoriteJobState extends State<FavoriteJobList> {
  late FavoriteJobPresenter _favoritePresenter;
  Map<String, JobData> _favorites = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _favoritePresenter = FavoriteJobPresenter(
        onFavoritesLoaded: (Map<String, JobData> favorites) {
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
        appBar: CommonAppBar(
          context: context,
          title: 'Favorite Jobs',
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  padding: const EdgeInsets.all(8.0),
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : (_favorites.isEmpty)
                ? const Center(
                    child: Text(
                        style: TextStyle(fontSize: 16.0),
                        'No favorite jobs yet'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _favorites.length,
                    itemBuilder: (BuildContext context, int index) {
                      JobData favorite =
                          _favorites.entries.elementAt(index).value;
                      return Card(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        child: ListTile(
                          title: Text(favorite.jobTitle),
                          subtitle: Text(
                              '${favorite.companyLocation} | ${favorite.formattedSalary}'),
                          trailing: IconButton(
                              onPressed: () => _removeFavorite(favorite.jobId),
                              icon: const Icon(Icons.close, color: Colors.red)),
                        ),
                      );
                    }));
  }
}
