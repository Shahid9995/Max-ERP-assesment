import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_model.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Summary'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Statistics Card
              Container(
                margin: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Present',
                          provider.presentDays.toString(),
                          Colors.green,
                          Icons.check_circle,
                        ),
                        _buildStatItem(
                          'Absent',
                          provider.absentDays.toString(),
                          Colors.red,
                          Icons.cancel,
                        ),
                        _buildStatItem(
                          'Late',
                          provider.lateDays.toString(),
                          Colors.orange,
                          Icons.schedule,
                        ),
                        _buildStatItem(
                          'Rate',
                          '${provider.attendancePercentage.toStringAsFixed(1)}%',
                          Colors.blue,
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Filter Chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: provider.selectedFilter == null,
                        onSelected: (selected) {
                          if (selected) {
                            provider.clearFilter();
                          }
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.blue[100],
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Present'),
                        selected: provider.selectedFilter == AttendanceStatus.present,
                        onSelected: (selected) {
                          provider.setFilter(selected ? AttendanceStatus.present : null);
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.green[100],
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Absent'),
                        selected: provider.selectedFilter == AttendanceStatus.absent,
                        onSelected: (selected) {
                          provider.setFilter(selected ? AttendanceStatus.absent : null);
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.red[100],
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Late'),
                        selected: provider.selectedFilter == AttendanceStatus.late,
                        onSelected: (selected) {
                          provider.setFilter(selected ? AttendanceStatus.late : null);
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.orange[100],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Attendance List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = provider.filteredRecords[index];
                    return _buildAttendanceCard(record);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    final dateFormatter = DateFormat('EEE, MMM d');
    final isToday = DateFormat('yyyy-MM-dd').format(record.date) == 
                   DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.statusColor.withOpacity(0.1),
          child: Icon(
            _getStatusIcon(record.status),
            color: record.statusColor,
          ),
        ),
        title: Row(
          children: [
            Text(
              dateFormatter.format(record.date),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (isToday) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.statusString,
                    style: TextStyle(
                      color: record.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (record.checkInTime != null || record.checkOutTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (record.checkInTime != null) ...[
                    Icon(Icons.login, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      record.checkInTime!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (record.checkInTime != null && record.checkOutTime != null)
                    const SizedBox(width: 16),
                  if (record.checkOutTime != null) ...[
                    Icon(Icons.logout, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      record.checkOutTime!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        trailing: record.status == AttendanceStatus.late
            ? Icon(Icons.warning, color: Colors.orange, size: 20)
            : null,
      ),
    );
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.schedule;
    }
  }
} 