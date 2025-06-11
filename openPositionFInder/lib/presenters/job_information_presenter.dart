import 'package:cs_3541_final_project/models/favorite_job_model.dart';
import 'package:cs_3541_final_project/models/job_information_model.dart';

class JobDataPresenter {
  final JobModel _jobModel;
  List<JobData> _dataScienceJobs = [];
  List<JobData> _softwareEngineeringJobs = [];
  final Function(List<JobData>) _updateUI;
  final Function(bool) _setLoading;
  final Function(String) _showError;

  JobDataPresenter(
    this._jobModel,
    this._updateUI,
    this._showError,
    this._setLoading,
  );

  List<JobData> getDataScienceJobs() {
    return _dataScienceJobs;
  }

  List<JobData> getSoftwareEngineeringJobs() {
    return _softwareEngineeringJobs;
  }

  Future<void> loadDataScienceJobs() async {
    _setLoading(true);

    try {
      _dataScienceJobs = await _jobModel.fetchDataScienceJobs();
      _updateUI(_dataScienceJobs);
    } catch (e) {
      _showError('Error loading jobs: $e');

      _updateUI([]);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSoftwareEngineeringJobs() async {
    _setLoading(true);

    try {
      _softwareEngineeringJobs = await _jobModel.fetchSoftwareEngineeringJobs();
      _updateUI(_softwareEngineeringJobs);
    } catch (e) {
      _showError('Error loading jobs: $e');

      _updateUI([]);
    } finally {
      _setLoading(false);
    }
  }

  void addFavorite(JobData job) {
    FavoriteJobModel.addFavorite(job);
  }

  void deleteFavorite(JobData job) {
    FavoriteJobModel.removeFavorite(job.jobId);
  }

  List<JobData> filterJobsByCompanySize(String companySize) {
    print('Filtering by company size: $companySize');
    print('Total DS jobs before filtering: ${_dataScienceJobs.length}');

    if (companySize == 'All') {
      return _dataScienceJobs;
    }

    String sizeCode = companySize;
    if (companySize == 'Small') sizeCode = 'S';
    if (companySize == 'Medium') sizeCode = 'M';
    if (companySize == 'Large') sizeCode = 'L';

    var filtered = _dataScienceJobs.where((job) {
      bool matches = job.companySize == sizeCode;
      if (!matches) {
        print(
            'Job ${job.jobTitle} has size "${job.companySize}" which doesn\'t match "$sizeCode"');
      }
      return matches;
    }).toList();

    print('Found ${filtered.length} jobs after filtering');

    if (filtered.isNotEmpty) {
      print(
          'First filtered job: ${filtered[0].jobTitle}, Company Size: ${filtered[0].companySize}');
    }

    return filtered;
  }

  double calculateAverageSalaryByCompanySize(String companySize) {
    final filteredJobs = filterJobsByCompanySize(companySize);

    if (filteredJobs.isEmpty) {
      print('No jobs found for company size: $companySize');
      return 0.0;
    }

    double totalSalary = 0.0;
    int validSalaryCount = 0;

    for (var job in filteredJobs) {
      double? salary = job.salaryInUsd.toDouble();
      if (salary > 0) {
        totalSalary += salary;
        validSalaryCount++;
      } else {
        print(
            'Failed to parse salary: "${job.salaryInUsd}" for ${job.jobTitle}');
      }
    }

    if (validSalaryCount == 0) {
      print('No valid salaries found for company size: $companySize');
      return 0.0;
    }

    double averageSalary = totalSalary / validSalaryCount;
    print(
        'Company Size: $companySize - Total Salary: $totalSalary, Count: $validSalaryCount, Average: $averageSalary');
    return averageSalary;
  }
}
