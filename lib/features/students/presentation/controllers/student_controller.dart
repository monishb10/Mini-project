import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';

class StudentController extends ChangeNotifier {
  final StudentRepository _repository;

  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedDepartment = 'All Departments';
  String _selectedYear = 'All Years';
  String _selectedRiskLevel = 'All Risk Levels';
  String _searchQuery = '';

  StudentController({StudentRepository? repository})
    : _repository = repository ?? MockStudentRepository() {
    loadStudents();
  }

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedDepartment => _selectedDepartment;
  String get selectedYear => _selectedYear;
  String get selectedRiskLevel => _selectedRiskLevel;
  String get searchQuery => _searchQuery;

  int get totalStudentsCount => _students.length;
  int get atRiskStudentsCount => _students.where((s) => s.isAtRisk).length;
  double get averageAttendance {
    if (_students.isEmpty) return 0.0;
    final total = _students.fold(0.0, (sum, s) => sum + s.attendanceRate);
    return total / _students.length;
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _students = await _repository.getStudents(
        department: _selectedDepartment,
        year: _selectedYear,
        riskLevel: _selectedRiskLevel,
        searchQuery: _searchQuery,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterDepartment(String department) {
    _selectedDepartment = department;
    loadStudents();
  }

  void filterYear(String year) {
    _selectedYear = year;
    loadStudents();
  }

  void filterRiskLevel(String riskLevel) {
    _selectedRiskLevel = riskLevel;
    loadStudents();
  }

  void search(String query) {
    _searchQuery = query;
    loadStudents();
  }

  Future<bool> addStudent(StudentModel student) async {
    try {
      await _repository.addStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(StudentModel student) async {
    try {
      await _repository.updateStudent(student);
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String id) async {
    try {
      await _repository.deleteStudent(id);
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
