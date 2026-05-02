import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/attendance_model.dart';
import '../../../models/session_model.dart';
import '../../../theme/app_theme.dart';

class SessionStatsWidget extends StatelessWidget {
  final List<AttendanceModel> attendance;
  final SessionModel session;

  const SessionStatsWidget({
    super.key,
    required this.attendance,
    required this.session,
  });

  int get _presentCount => attendance.where((a) => a.isPresent).length;
  int get _revokedCount => attendance.where((a) => a.isRevoked).length;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          ),
          child: Row(
            children: [
              _StatTile(
                value: _presentCount.toString(),
                label: 'Present',
                color: const Color(0xFF22C55E),
                icon: Icons.check_circle_outline_rounded,
              ),
              _Divider(),
              _StatTile(
                value: _revokedCount.toString(),
                label: 'Revoked',
                color: const Color(0xFFEF4444),
                icon: Icons.cancel_outlined,
              ),
              _Divider(),
              _StatTile(
                value: attendance.length.toString(),
                label: 'Total',
                color: AppTheme.primary,
                icon: Icons.people_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatTile({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: const Color(0x1AFFFFFF));
  }
}
