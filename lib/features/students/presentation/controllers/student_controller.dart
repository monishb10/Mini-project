import 'package:flutter/material.dart';
import '../../../../core/services/firebase_service.dart';
import '../../data/models/csv_import_result.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/firestore_student_repository.dart';
import '../../data/repositories/student_repository.dart';

class StudentController extends ChangeNotifier {
  final StudentRepository _repository;

  List<StudentModel> _students = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  CsvImportResult? _lastImportResult;

  String _selectedDepartment = 'All Departments';
  String _selectedYear = 'All Years';
  String _selectedRiskLevel = 'All Risk Levels';
  String _searchQuery = '';

  StudentController({StudentRepository? repository})
      : _repository = repository ??
            (FirebaseService.isInitialized
                ? FirestoreStudentRepository()
                : MockStudentRepository()) {
    loadStudents();
  }

  List<StudentModel> get students => _students;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  CsvImportResult? get lastImportResult => _lastImportResult;

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
      _errorMessage = _cleanError(e);
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

  Future<bool> addStudent(StudentModel student, {bool isAdmin = true}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.addStudent(student, isAdmin: isAdmin);
      _successMessage = 'Student "${student.name}" (${student.rollNumber}) created successfully.';
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStudent(StudentModel student, {bool isAdmin = true}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.updateStudent(student, isAdmin: isAdmin);
      _successMessage = 'Student record for "${student.name}" updated successfully.';
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteStudent(String id, {bool isAdmin = true}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deleteStudent(id, isAdmin: isAdmin);
      _successMessage = 'Student record deleted successfully.';
      await loadStudents();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<CsvImportResult?> importCsv(String csvContent, {bool isAdmin = true}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _repository.importStudentsFromCsv(csvContent, isAdmin: isAdmin);
      _lastImportResult = result;
      if (result.importedCount > 0) {
        _successMessage = 'CSV Import complete: ${result.importedCount} student(s) imported successfully.';
        await loadStudents();
      } else if (result.hasErrors) {
        _errorMessage = 'CSV Import completed with ${result.errors.length} validation error(s). No records added.';
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  String _cleanError(dynamic e) {
    String msg = e.toString();
    if (msg.startsWith('Exception: ')) {
      msg = msg.substring(11);
    }
    return msg;
  }
}
