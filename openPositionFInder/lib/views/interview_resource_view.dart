import 'package:cs_3541_final_project/models/favorite_job_model.dart';
import 'package:cs_3541_final_project/models/interview_resource_model.dart';
import 'package:cs_3541_final_project/presenters/interview_resource_presenter.dart';
import 'package:cs_3541_final_project/views/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'favorite_resource_view.dart';

class InterviewResourcePage extends StatelessWidget {
  const InterviewResourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: InterviewResourceList(),
    );
  }
}

class InterviewResourceList extends StatefulWidget {
  const InterviewResourceList({super.key});

  @override
  State<InterviewResourceList> createState() => _InterviewResourceState();
}

class _InterviewResourceState extends State<InterviewResourceList> {
  late ResourcePresenter _resourcePresenter;
  List<ResourceData> _resourceList = [];
  bool _isLoading = false;
  String? _errorMessage;
  Set<String> currentFavorites = {};

  @override
  void initState() {
    super.initState();

    _resourcePresenter = ResourcePresenter(
        ResourceModel(),
        (resourceList) => setState(() => _resourceList = resourceList),
        (isLoading) => setState(() => _isLoading = isLoading),
        (errorMessage) => setState(() => _errorMessage = errorMessage));
    _resourcePresenter.loadResources();
    _getFavorites();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _resourcePresenter.loadResources();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getFavorites() async {
    FavoriteResourceModel.getFavorites().then((favorites) {
      setState(() {
        currentFavorites =
            favorites.map((element) => element.resourceName).toSet();
      });
    });
  }

  void newFavorite(ResourceData resource) {
    setState(() {
      currentFavorites.add(resource.resourceName);
      _resourcePresenter.addFavorite(resource);
    });
  }

  void deleteFavorite(ResourceData resource) {
    setState(() {
      currentFavorites.remove(resource.resourceName);
      _resourcePresenter.deleteFavorite(resource);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context,
        title: 'Interview Resources',
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoriteResourceView()));
              _refreshData();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(padding: EdgeInsets.all(8.0)))
          : (_resourceList.isEmpty)
              ? const Center(
                  child: Text(
                      style: TextStyle(fontSize: 16.0), 'No resources found'),
                )
              : ListView.builder(
                  itemCount: _resourceList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final resource = _resourceList[index];
                    final uri = Uri.parse(resource.url);
                    final image = resource.imagePath;
                    final isFavorite =
                        currentFavorites.contains(resource.resourceName);

                    return Card(
                      elevation: 3.0,
                      color: Theme.of(context).colorScheme.surface,
                      child: ListTile(
                        leading: IconButton(
                            icon: Icon(isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border),
                            color: isFavorite ? Colors.red : null,
                            onPressed: () {
                              if (isFavorite) {
                                deleteFavorite(resource);
                              } else {
                                newFavorite(resource);
                              }
                            }),
                        title: Column(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(image),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Text(
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w500),
                                resource.resourceName),
                          ],
                        ),
                        trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => launchUrl(uri)),
                      ),
                    );
                  }),
    );
  }
}
