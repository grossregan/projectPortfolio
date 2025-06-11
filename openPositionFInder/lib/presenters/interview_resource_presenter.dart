import 'package:cs_3541_final_project/models/interview_resource_model.dart';

class ResourcePresenter {
  final ResourceModel _resourceModel;
  final firestoreInstructions = FirestoreInstructions();
  List<ResourceData> _resourceList = [];
  final Function(List<ResourceData>) _updateUI;
  final Function(bool) _setLoading;
  final Function(String) _showError;

  ResourcePresenter(
    this._resourceModel,
    this._updateUI,
    this._setLoading,
    this._showError,
  );

  List<ResourceData> getResources() {
    return _resourceList;
  }

  Future<void> loadResources() async {
    _setLoading(true);

    try {
      _resourceList = await _resourceModel.fetchResources();
      _updateUI(_resourceList);
    } catch (e) {
      _showError('Error loading resources: $e');

      _updateUI([]);
    } finally {
      _setLoading(false);
    }
  }

  void addFavorite(ResourceData resource) {
    firestoreInstructions.addFavorite(resource);
  }

  void deleteFavorite(ResourceData resource) {
    firestoreInstructions.deleteFavorite(resource);
  }
}
