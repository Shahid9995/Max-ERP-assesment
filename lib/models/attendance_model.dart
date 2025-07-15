import 'package:flutter/material.dart';

enum AttendanceStatus {
  present,
  absent,
  late,
}

class AttendanceRecord {
  final DateTime date;
  final AttendanceStatus status;
  final String? checkInTime;
  final String? checkOutTime;

  AttendanceRecord({
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
  });

  String get statusString {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
    }
  }

  Color get statusColor {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
    }
  }
} 