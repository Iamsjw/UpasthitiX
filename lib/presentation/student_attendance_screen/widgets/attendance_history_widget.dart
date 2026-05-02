import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/attendance_model.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/status_badge_widget.dart';

class AttendanceHistoryWidget extends StatelessWidget {
  final List<AttendanceModel> history;

  const AttendanceHistoryWidget({super.key, required this.history});

  Map<String, List<AttendanceModel>> get _grouped {
    final map = <String, List<AttendanceModel>>{};
    for (final record in history) {
      final date = _formatDate(record.timestamp);
      map.putIfAbsent(date, () => []).add(record);
    }
    return map;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.day == yesterday.day &&
        dt.month == yesterday.month &&
        dt.year == yesterday.year) {
      return 'Yesterday';
    }
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
  }

  // Subject-wise attendance summary
  Map<String, _SubjectSummary> get _subjectSummary {
    final map = <String, _SubjectSummary>{};
    for (final record in history) {
      final key = record.sessionId; // group by session
      if (!map.containsKey(key)) {
        map[key] = _SubjectSummary(sessionId: key, total: 0, present: 0);
      }
      map[key]!.total++;
      if (record.isPresent) map[key]!.present++;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 16,
                          color: Color(0x99FFFFFF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Attendance History',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0x99FFFFFF),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1A22D3EE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${history.where((h) => h.isPresent).length} present',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF22D3EE),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0x0DFFFFFF)),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: EmptyStateWidget(
                    icon: Icons.event_available_outlined,
                    title: 'No Attendance Yet',
                    description:
                        'Your attendance records will appear here once you mark attendance in a session.',
                  ),
                )
              else ...[
                // Summary stats
                _buildSummaryRow(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0x0DFFFFFF),
                ),
                // Records grouped by date
                ..._grouped.entries.map(
                  (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                        child: Text(
                          entry.key,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0x66FFFFFF),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...entry.value.map(
                        (record) => _HistoryRow(
                          record: record,
                          formatTime: _formatTime,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final present = history.where((h) => h.isPresent).length;
    final revoked = history.where((h) => h.isRevoked).length;
    final total = history.length;
    final rate = total == 0 ? 0.0 : present / total;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _SummaryTile(
              value: present.toString(),
              label: 'Present',
              color: const Color(0xFF22C55E),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0x14FFFFFF)),
          Expanded(
            child: _SummaryTile(
              value: revoked.toString(),
              label: 'Revoked',
              color: const Color(0xFFEF4444),
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0x14FFFFFF)),
          Expanded(
            child: _SummaryTile(
              value: '${(rate * 100).toStringAsFixed(0)}%',
              label: 'Rate',
              color: rate >= 0.75
                  ? const Color(0xFF22C55E)
                  : rate >= 0.5
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryTile({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0x66FFFFFF),
          ),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final AttendanceModel record;
  final String Function(DateTime) formatTime;

  const _HistoryRow({required this.record, required this.formatTime});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: record.isPresent
                  ? const Color(0x1A22C55E)
                  : const Color(0x1AEF4444),
            ),
            child: Icon(
              record.isPresent ? Icons.check_rounded : Icons.close_rounded,
              color: record.isPresent
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session ${record.sessionId.substring(0, 8).toUpperCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  formatTime(record.timestamp),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0x66FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          StatusBadgeWidget.attendanceStatus(
            record.isPresent
                ? AttendanceStatus.present
                : AttendanceStatus.revoked,
          ),
        ],
      ),
    );
  }
}

class _SubjectSummary {
  final String sessionId;
  int total;
  int present;

  _SubjectSummary({
    required this.sessionId,
    required this.total,
    required this.present,
  });
}
