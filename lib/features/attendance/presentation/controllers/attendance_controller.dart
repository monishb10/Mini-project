import 'package:flutter/material.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/firestore_attendance_repository.dart';

class AttendanceController extends ChangeNotifier {
  final AttendanceRepository _repository;

  List<AttendanceRecord> _records = [];
  String _selectedEventId = 'evt_01';
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  AttendanceController({AttendanceRepository? repository})
      : _repository = repository ??
            (FirebaseService.isInitialized
                ? FirestoreAttendanceRepository()
                : MockAttendanceRepository()) {
    loadAttendance(_selectedEventId);
  }

  List<AttendanceRecord> get records => _records;
  String get selectedEventId => _selectedEventId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  int get presentCount => _records.where((r) => r.status == 'Present').length;
  int get absentCount => _records.where((r) => r.status == 'Absent').length;
  int get excusedCount => _records.where((r) => r.status == 'Excused').length;
  int get totalRecords => _records.length;

  double get attendancePercentage =>
      totalRecords == 0 ? 0.0 : (presentCount / totalRecords) * 100;

  Future<void> loadAttendance(String eventId) async {
    _selectedEventId = eventId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _repository.getAttendanceForEvent(eventId);
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatus(
    String recordId,
    String newStatus, {
    UserModel? user,
  }) async {
    _errorMessage = null;
    _successMessage = null;
    try {
      final updated = await _repository.updateStatus(
        recordId,
        newStatus,
        markedBy: user?.name,
        verifyingUserId: user?.uid,
      );
      final index = _records.indexWhere((r) => r.id == recordId);
      if (index != -1) {
        _records[index] = updated;
      }
      _successMessage =
          'Roll-call status for ${updated.studentName} updated to "$newStatus".';
      notifyListeners();
    } catch (e) {
      _errorMessage = _cleanError(e);
      notifyListeners();
    }
  }

  Future<void> bulkMarkPresent({UserModel? user}) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.bulkMarkPresent(
        _selectedEventId,
        markedBy: user?.name,
        verifyingUserId: user?.uid,
      );
      _successMessage = 'All registered students marked as Present.';
      await loadAttendance(_selectedEventId);
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> quickCheckIn(
    String rollNumber,
    String markedBy, {
    String? verifyingUserId,
    String checkInMode = 'Manual Roll Call',
  }) async {
    _errorMessage = null;
    _successMessage = null;
    try {
      final record = await _repository.recordQuickCheckIn(
        eventId: _selectedEventId,
        rollNumber: rollNumber,
        markedBy: markedBy,
        verifyingUserId: verifyingUserId,
        checkInMode: checkInMode,
      );

      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record;
      } else {
        _records.insert(0, record);
      }

      _successMessage =
          'Attendance recorded for ${record.studentName} (${record.studentRollNumber}).';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyAndRecordQrCheckIn({
    required String eventId,
    required String rollNumber,
    required String qrToken,
    required UserModel verifyingUser,
  }) async {
    _errorMessage = null;
    _successMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final record = await _repository.verifyAndRecordQrCheckIn(
        eventId: eventId,
        studentRollNumber: rollNumber,
        qrToken: qrToken,
        markedBy: verifyingUser.name,
        verifyingUserId: verifyingUser.uid,
      );

      final index = _records.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _records[index] = record;
      } else {
        _records.insert(0, record);
      }

      _successMessage =
          'QR Verification Verified: Check-in recorded for ${record.studentName} (${record.studentRollNumber})!';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
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
