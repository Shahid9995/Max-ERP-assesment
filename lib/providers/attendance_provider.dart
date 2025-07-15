import 'package:flutter/material.dart';
import '../models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  List<AttendanceRecord> _attendanceRecords = [];
  AttendanceStatus? _selectedFilter;

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceStatus? get selectedFilter => _selectedFilter;

  List<AttendanceRecord> get filteredRecords {
    if (_selectedFilter == null) {
      return _attendanceRecords;
    }
    return _attendanceRecords.where((record) => record.status == _selectedFilter).toList();
  }

  AttendanceProvider() {
    _generateDummyData();
  }

  void _generateDummyData() {
    final now = DateTime.now();
    _attendanceRecords = [
      AttendanceRecord(
        date: now.subtract(const Duration(days: 6)),
        status: AttendanceStatus.present,
        checkInTime: '09:00 AM',
        checkOutTime: '05:30 PM',
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 5)),
        status: AttendanceStatus.late,
        checkInTime: '09:45 AM',
        checkOutTime: '05:30 PM',
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 4)),
        status: AttendanceStatus.present,
        checkInTime: '08:50 AM',
        checkOutTime: '05:45 PM',
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 3)),
        status: AttendanceStatus.absent,
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 2)),
        status: AttendanceStatus.present,
        checkInTime: '09:15 AM',
        checkOutTime: '05:30 PM',
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 1)),
        status: AttendanceStatus.late,
        checkInTime: '09:30 AM',
        checkOutTime: '05:30 PM',
      ),
      AttendanceRecord(
        date: now,
        status: AttendanceStatus.present,
        checkInTime: '08:45 AM',
        checkOutTime: '05:30 PM',
      ),
    ];
  }

  void setFilter(AttendanceStatus? status) {
    _selectedFilter = status;
    notifyListeners();
  }

  void clearFilter() {
    _selectedFilter = null;
    notifyListeners();
  }

  // Statistics methods
  int get totalDays => _attendanceRecords.length;
  int get presentDays => _attendanceRecords.where((r) => r.status == AttendanceStatus.present).length;
  int get absentDays => _attendanceRecords.where((r) => r.status == AttendanceStatus.absent).length;
  int get lateDays => _attendanceRecords.where((r) => r.status == AttendanceStatus.late).length;

  double get attendancePercentage => presentDays / totalDays * 100;
} 