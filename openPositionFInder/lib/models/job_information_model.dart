import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class JobModel {
  Future<List<JobData>> fetchDataScienceJobs() async {
    final dataScienceSalaries =
        await rootBundle.loadString('assets/data/data_science_salaries.json');

    final List<dynamic> dataScienceData = json.decode(dataScienceSalaries);
    return dataScienceData
        .map((json) => JobData.fromDataScienceJson(json))
        .toList();
  }

  Future<List<JobData>> fetchSoftwareEngineeringJobs() async {
    final softwareEngineeringSalaries = await rootBundle
        .loadString('assets/data/software_engineering_salaries.json');

    final List<dynamic> softwareEngineeringData =
        json.decode(softwareEngineeringSalaries);
    return softwareEngineeringData
        .map((json) => JobData.fromSoftwareEngineeringJson(json))
        .toList();
  }
}

enum ExperienceLevel {
  entry(name: 'Entry-level'),
  mid(name: 'Mid-level'),
  senior(name: 'Senior'),
  executive(name: 'Executive');

  final String name;
  const ExperienceLevel({required this.name});
}

enum EmploymentType {
  fullTime(name: 'Full-time'),
  partTime(name: 'Part-time'),
  contract(name: 'Contract'),
  freelance(name: 'Freelance');

  final String name;
  const EmploymentType({required this.name});
}

enum CompanySize {
  small(name: 'Small'),
  medium(name: 'Medium'),
  large(name: 'Large');

  final String name;
  const CompanySize({required this.name});
}

enum WorkSetting {
  remote(name: 'Remote'),
  hybrid(name: 'Hybrid'),
  inPerson(name: 'In-person');

  final String name;
  const WorkSetting({required this.name});
}

enum JobCategory {
  dataEngineering(name: 'Data Engineering'),
  dataArchitectureAndModeling(name: 'Data Architecture and Modeling'),
  dataScienceAndResearch(name: 'Data Science and Research'),
  machineLearningAndAI(name: 'Machine Learning and AI'),
  dataAnalysis(name: 'Data Analysis'),
  leadershipAndManagement(name: 'Leadership and Management'),
  biAndVisualization(name: 'BI and Visualization'),
  dataQualityAndOperations(name: 'Data Quality and Operations'),
  dataManagementAndStrategy(name: 'Data Management and Strategy'),
  cloudAndDatabase(name: 'Cloud and Database');

  final String name;
  const JobCategory({required this.name});
}

enum JobType {
  dataScience(name: 'Data Science'),
  softwareEngineering(name: 'Software Engineering');

  final String name;
  const JobType({required this.name});
}

// ignore: constant_identifier_names
enum SalaryCurrency { USD, TRY, SGD, PLN, GBP, EUR, DKK, CHF, CAD, BRL, AUD }

class JobData {
  // Fields in both
  /// A string value representing the unique job ID.
  ///
  /// This is in the format of data_science_1 or software_engineering_1.
  ///
  /// Note that the keys are 1-indexed, so the first job is data_science_1
  /// or software_engineering_1, not data_science_0 or software_engineering_0
  final String jobId;

  /// A string value representing the job title
  final String jobTitle;

  /// An integer value representing the yearly salary in USD
  final int salaryInUsd;

  /// A string value representing the company location.
  ///
  /// For Data Science, this is a country name.
  /// For Software Engineering, this follows the pattern City, State (abbr.)
  final String companyLocation;

  // ----------------------
  // Fields in Data Science
  /// Only available for JobType.dataScience
  ///
  /// An enum value representing the job category
  final JobCategory? jobCategory;

  /// Only available for JobType.dataScience
  ///
  /// An enum value representing the experience level needed for the job
  final ExperienceLevel? experienceLevel;

  /// Only available for JobType.dataScience
  ///
  /// An enum value representing the type of employment
  final EmploymentType? employmentType;

  /// Only available for JobType.dataScience
  ///
  /// An enum value representing the work setting
  /// (remote, hybrid, in-person)
  final WorkSetting? workSetting;

  /// Only available for JobType.dataScience
  ///
  /// An enum value representing the size of the company
  final CompanySize? companySize;

  /// Only available for JobType.dataScience
  ///
  /// A string value representing the country of the employee's residence
  final String? employeeResidence; // UNUSED

  /// Only available for JobType.dataScience
  ///
  /// An integer value representing the job yearly salary in the country's currency
  final int? salary; // UNUSED

  /// Only available for JobType.dataScience
  ///
  /// An enum value representing the currency of the salary
  final SalaryCurrency? salaryCurrency; // UNUSED

  /// Only available for JobType.dataScience
  ///
  /// An integer value representing the year the job is available
  final int? workYear; // UNUSED

  // ----------------------
  // Fields in Software Engineering
  /// Only available for JobType.softwareEngineering
  ///
  /// A string value representing the company name
  final String? companyName;

  /// Only available for JobType.softwareEngineering
  ///
  /// A double value representing the company score
  /// (0.0 - 5.0) based on the Glassdoor rating
  final double? companyScore;

  /// Only available for JobType.softwareEngineering
  ///
  /// I actually have no idea what this is supposed to be
  final String? date; // UNUSED

  const JobData({
    required this.jobId,
    required this.jobTitle,
    required this.companyLocation,
    required this.salaryInUsd,
    this.experienceLevel,
    this.employmentType,
    this.jobCategory,
    this.companySize,
    this.workSetting,
    this.employeeResidence,
    this.salary,
    this.salaryCurrency,
    this.workYear,
    this.companyName,
    this.companyScore,
    this.date,
  });

  /// Returns the job type based on the job ID.
  JobType get type => jobId.startsWith('data_science')
      ? JobType.dataScience
      : JobType.softwareEngineering;

  /// Returns the salary as a locale-formatted string
  String get formattedSalary =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(salaryInUsd);

  /// Creates a JobData object from JSON data
  /// formatted from the Data Science dataset
  factory JobData.fromDataScienceJson(Map<String, dynamic> json) {
    return JobData(
      jobId: json['job_id'],
      jobTitle: json['job_title'],
      companyLocation: json['company_location'],
      salaryInUsd: int.parse(json['salary_in_usd'].toString()),
      experienceLevel: ExperienceLevel.values
          .firstWhere((e) => e.name == json['experience_level']),
      employmentType: EmploymentType.values
          .firstWhere((e) => e.name == json['employment_type']),
      jobCategory:
          JobCategory.values.firstWhere((e) => e.name == json['job_category']),
      companySize:
          CompanySize.values.firstWhere((e) => e.name == json['company_size']),
      workSetting:
          WorkSetting.values.firstWhere((e) => e.name == json['work_setting']),
      employeeResidence: json['employee_residence'],
      salary: int.parse(json['salary'].toString()),
      salaryCurrency: SalaryCurrency.values
          .firstWhere((e) => e.name == json['salary_currency']),
      workYear: int.parse(json['work_year'].toString()),
    );
  }

  /// Creates a JobData object from JSON data
  /// formatted from the Software Engineering dataset
  factory JobData.fromSoftwareEngineeringJson(Map<String, dynamic> json) {
    return JobData(
      jobId: json['job_id'],
      jobTitle: json['job_title'],
      companyLocation: json['company_location'],
      salaryInUsd: int.parse(json['salary_in_usd'].toString()),
      date: json['date'],
      companyName: json['company_name'],
      companyScore: double.parse(json['company_score'].toString()),
    );
  }

  /// Creates a JobData object from JSON data
  /// formatted from either the Data Science or Software Engineering dataset
  /// based on the job ID
  factory JobData.fromMap(Map<String, dynamic> json) {
    if (json['job_id'].startsWith('data_science')) {
      return JobData.fromDataScienceJson(json);
    } else if (json['job_id'].startsWith('software_engineering')) {
      return JobData.fromSoftwareEngineeringJson(json);
    } else {
      throw Exception('Invalid job type');
    }
  }

  /// Converts the JobData object to a JSON map
  Map<String, dynamic> toMap() {
    return {
      'job_id': jobId,
      'job_title': jobTitle,
      'company_location': companyLocation,
      'salary_in_usd': salaryInUsd,
      'experience_level': experienceLevel?.name,
      'employment_type': employmentType?.name,
      'job_category': jobCategory?.name,
      'company_size': companySize?.name,
      'work_setting': workSetting?.name,
      'employee_residence': employeeResidence,
      'salary': salary,
      'salary_currency': salaryCurrency?.name,
      'work_year': workYear,
      'company_name': companyName,
      'company_score': companyScore,
      'date': date,
    };
  }

  /// See the details of the job
  String get details => '''Title: $jobTitle
Location: $companyLocation
Salary: $formattedSalary
${type == JobType.dataScience ? '''
Original Salary: ${NumberFormat.currency(name: '${salaryCurrency?.name} ').format(salary)}
Experience Level: ${experienceLevel?.name}
Employment Type: ${employmentType?.name}
Work Setting: ${workSetting?.name}
Company Size: ${companySize?.name}
''' : '''
Company Name: $companyName
Company Score: $companyScore'''}''';
}
