import 'package:flutter/material.dart';
import '../../data/models/analytics_model.dart';
import '../../data/repositories/analytics_repository.dart';

class AnalyticsController extends ChangeNotifier {
  final AnalyticsRepository _repository;

  AnalyticsSummary? _summary;
  List<CategoryParticipation> _categoryData = [];
  List<DepartmentParticipation> _departmentData = [];
  List<MonthlyTrendPoint> _monthlyTrend = [];
  bool _isLoading = false;
  String? _errorMessage;

  AnalyticsController({AnalyticsRepository? repository})
    : _repository = repository ?? MockAnalyticsRepository() {
    loadAnalytics();
  }

  AnalyticsSummary? get summary => _summary;
  List<CategoryParticipation> get categoryData => _categoryData;
  List<DepartmentParticipation> get departmentData => _departmentData;
  List<MonthlyTrendPoint> get monthlyTrend => _monthlyTrend;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAnalytics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getSummary(),
        _repository.getCategoryParticipation(),
        _repository.getDepartmentParticipation(),
        _repository.getMonthlyTrend(),
      ]);

      _summary = results[0] as AnalyticsSummary;
      _categoryData = results[1] as List<CategoryParticipation>;
      _departmentData = results[2] as List<DepartmentParticipation>;
      _monthlyTrend = results[3] as List<MonthlyTrendPoint>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
