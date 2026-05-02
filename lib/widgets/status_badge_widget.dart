import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AttendanceStatus { present, revoked, pending, absent }

enum SessionStatus { active, expired, notStarted }

class StatusBadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadgeWidget({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.fontSize = 11,
    this.padding,
  });

  factory StatusBadgeWidget.attendanceStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return StatusBadgeWidget(
          label: 'PRESENT',
          color: const Color(0x3322C55E),
          textColor: const Color(0xFF22C55E),
        );
      case AttendanceStatus.revoked:
        return StatusBadgeWidget(
          label: 'REVOKED',
          color: const Color(0x33EF4444),
          textColor: const Color(0xFFEF4444),
        );
      case AttendanceStatus.absent:
        return StatusBadgeWidget(
          label: 'ABSENT',
          color: const Color(0x33F59E0B),
          textColor: const Color(0xFFF59E0B),
        );
      case AttendanceStatus.pending:
        return StatusBadgeWidget(
          label: 'PENDING',
          color: const Color(0x336C63FF),
          textColor: const Color(0xFF6C63FF),
        );
    }
  }

  factory StatusBadgeWidget.sessionStatus(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return StatusBadgeWidget(
          label: '● LIVE',
          color: const Color(0x3322C55E),
          textColor: const Color(0xFF22C55E),
        );
      case SessionStatus.expired:
        return StatusBadgeWidget(
          label: 'EXPIRED',
          color: const Color(0x33EF4444),
          textColor: const Color(0xFFEF4444),
        );
      case SessionStatus.notStarted:
        return StatusBadgeWidget(
          label: 'INACTIVE',
          color: const Color(0x14FFFFFF),
          textColor: const Color(0x66FFFFFF),
        );
    }
  }

  factory StatusBadgeWidget.role(String role) {
    Color bg, fg;
    switch (role.toLowerCase()) {
      case 'admin':
        bg = const Color(0x33FF6B6B);
        fg = const Color(0xFFFF6B6B);
        break;
      case 'teacher':
        bg = const Color(0x336C63FF);
        fg = const Color(0xFF6C63FF);
        break;
      default:
        bg = const Color(0x3322D3EE);
        fg = const Color(0xFF22D3EE);
    }
    return StatusBadgeWidget(
      label: role.toUpperCase(),
      color: bg,
      textColor: fg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
