import 'package:flutter/material.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';

class ReportController extends ChangeNotifier {
  final ReportRepository _repository;

  List<ReportModel> _reports = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;

  ReportController({ReportRepository? repository})
    : _repository = repository ?? MockReportRepository() {
    loadReports();
  }

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;

  Future<void> loadReports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reports = await _repository.getReports();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generateReport({
    required String title,
    required String reportType,
    required String department,
    required String academicYear,
    required String format,
  }) async {
    _isGenerating = true;
    notifyListeners();

    try {
      final newReport = await _repository.generateReport(
        title: title,
        reportType: reportType,
        department: department,
        academicYear: academicYear,
        format: format,
      );
      _reports.insert(0, newReport);
      _isGenerating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReport(String id) async {
    try {
      await _repository.deleteReport(id);
      _reports.removeWhere((r) => r.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
