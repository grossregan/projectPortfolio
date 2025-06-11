import 'package:cs_3541_final_project/models/favorite_job_model.dart';
import 'package:cs_3541_final_project/models/job_information_model.dart';
import 'package:cs_3541_final_project/presenters/job_information_presenter.dart';
import 'package:cs_3541_final_project/views/common_app_bar.dart';
import 'package:cs_3541_final_project/views/favorite_job_view.dart';
import 'package:cs_3541_final_project/views/interview_resource_view.dart';
import 'package:flutter/material.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  late SearchController _searchController; //for search bar
  late JobDataPresenter _dataScienceDataPresenter;
  late JobDataPresenter _softwareEngineeringDataPresenter;
  List<JobData> _dataScienceJobs = [];
  List<JobData> _softwareEngineeringJobs = [];

  /// A set of jobs that are currently favorited.
  Map<String, JobData> currentFavorites = {};
  bool _isLoading = false;
  String _searchQuery = ''; //for search bar
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _searchController = SearchController();
    _searchController.addListener(() =>
        setState(() => _searchQuery = _searchController.text.toLowerCase()));

    _initializeData();
    _getFavorites();
  }

  void _initializeData() {
    //Refactoring suggested by Claude.ai, May 2025
    _dataScienceDataPresenter = JobDataPresenter(
      JobModel(),
      (jobs) => setState(() => _dataScienceJobs = jobs),
      (error) => setState(() => _errorMessage = error),
      (isLoading) => setState(() => _isLoading = isLoading),
    );

    _softwareEngineeringDataPresenter = JobDataPresenter(
        JobModel(),
        (jobs) => setState(() => _softwareEngineeringJobs = jobs),
        (error) => setState(() => _errorMessage = error),
        (isLoading) => setState(() => _isLoading = isLoading));

    _loadData();
  }

  Future<void> _loadData() async {
    _dataScienceDataPresenter.loadDataScienceJobs();
    _softwareEngineeringDataPresenter.loadSoftwareEngineeringJobs();
    _getFavorites();
  }

  //for search bar
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getFavorites() async {
    FavoriteJobModel.getFavorites()
        .then((favorites) => setState(() => currentFavorites = favorites));
  }

  Future<void> _refreshData() async {
    //Built with suggestions from Claude.ai- May,2025
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _loadData();
    setState(() {
      _isLoading = false;
    });
  }

  void newFavorite(JobData job) {
    setState(() {
      currentFavorites[job.jobId] = job;

      switch (job.type) {
        case JobType.softwareEngineering:
          _softwareEngineeringDataPresenter.addFavorite(job);
          break;
        case JobType.dataScience:
          _dataScienceDataPresenter.addFavorite(job);
          break;
      }
    });
  }

  void deleteFavorite(JobData job) {
    setState(() {
      currentFavorites.remove(job.jobId);
      switch (job.type) {
        case JobType.softwareEngineering:
          _softwareEngineeringDataPresenter.deleteFavorite(job);
          break;
        case JobType.dataScience:
          _dataScienceDataPresenter.deleteFavorite(job);
          break;
      }
    });
  }

  void onFavoriteToggle(JobData job) {
    if (currentFavorites.containsKey(job.jobId)) {
      deleteFavorite(job);
    } else {
      newFavorite(job);
    }
  }

  static const List<Tab> tabs = [
    Tab(text: 'Software Engineering'),
    Tab(text: 'Data Science'),
  ];

  @override
  Widget build(BuildContext context) {
    //for app bar
    List<JobData> filteredDataScienceJobs = _dataScienceJobs
        .where((job) => job.jobTitle.toLowerCase().contains(_searchQuery))
        .toList();

    List<JobData> filteredSoftwareEngineeringJobs = _softwareEngineeringJobs
        .where((job) => job.jobTitle.toLowerCase().contains(_searchQuery))
        .toList();

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: CommonAppBar(
          context: context,
          title: 'Job Information',
          actions: [
            IconButton(
              icon: const Icon(Icons.question_mark),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InterviewResourcePage())),
            ),
            IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoriteJobView()),
                  );
                  _refreshData();
                }, //asynchronized by suggestion from Claude.ai- May 2025
                icon: const Icon(Icons.favorite)),
          ],
          bottom: const TabBar(tabs: tabs),
        ),
        body: Column(
          children: <Widget>[
            //search bar widget
            SearchAnchor(
              viewBarPadding: const EdgeInsets.only(bottom: 10),
              searchController: _searchController,
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  hintText: 'Search job titles...',
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                // Optional: You can return suggestions here from job list
                return [];
              },
            ),
            //Search bar widget

            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  padding: EdgeInsets.all(8.0),
                ),
              ),
            if (_errorMessage != null)
              Container(
                color: Colors.amber,
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),

            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  JobList(
                      jobs: filteredSoftwareEngineeringJobs,
                      currentFavorites: currentFavorites,
                      onFavoriteToggle: onFavoriteToggle),
                  JobList(
                      jobs: filteredDataScienceJobs,
                      currentFavorites: currentFavorites,
                      onFavoriteToggle: onFavoriteToggle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobList extends StatelessWidget {
  final List<JobData> jobs;
  final Map<String, JobData> currentFavorites;
  final Function(JobData) onFavoriteToggle;

  const JobList({
    super.key,
    required this.jobs,
    required this.onFavoriteToggle,
    required this.currentFavorites,
  });
  void Function() showJobDetails(BuildContext context, JobData job) =>
      () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          builder: (context) => FractionallySizedBox(
                heightFactor: job.type == JobType.dataScience ? 0.4 : 0.35,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close')),
                        ),
                        Text('Job Details',
                            style: Theme.of(context).textTheme.headlineSmall),
                        JobDetails(job: job)
                      ]),
                ),
              ));

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: jobs.length,
      itemBuilder: (BuildContext context, int index) {
        final JobData job = jobs[index];
        final isFavorited = currentFavorites.containsKey(job.jobId);

        return GestureDetector(
          onTap: showJobDetails(context, job),
          child: Card(
            elevation: 3.0,
            color: Theme.of(context).colorScheme.surface,
            child: ListTile(
              leading: IconButton(
                  icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.red : null),
                  onPressed: () => onFavoriteToggle(job)),
              title: Text(job.jobTitle),
              subtitle: Text(
                '${job.type == JobType.softwareEngineering ? '${job.companyName} | ' : ''}${job.companyLocation} | ${job.formattedSalary}',
              ),
            ),
          ),
        );
      },
    );
  }
}

class JobDetails extends StatelessWidget {
  final JobData job;
  const JobDetails({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final Map<String?, dynamic> children = {
      'Job Title': job.jobTitle,
      'Location': job.companyLocation,
      'Salary': job.formattedSalary,
    };
    if (job.type == JobType.dataScience) {
      children.addAll({
        'Experience Level': job.experienceLevel?.name,
        'Employment Type': job.employmentType?.name,
        'Work Setting': job.workSetting?.name,
        'Company Size': job.companySize?.name,
      });
    } else if (job.type == JobType.softwareEngineering) {
      children.addAll({
        'Company Name': job.companyName,
        'Company Score': job.companyScore.toString(),
      });
    }
    return Column(children: [
      for (var entry in children.entries)
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${entry.key}: ',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              entry.value,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ])
    ]);
  }
}
