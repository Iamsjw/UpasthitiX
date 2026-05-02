import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/attendance_model.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glass_card_widget.dart';

class SessionConfigWidget extends StatelessWidget {
  final List<ClassModel> classes;
  final List<SubjectModel> subjects;
  final List<AssignmentModel> assignments;
  final String? selectedClassId;
  final String? selectedSubjectId;
  final int durationSeconds;
  final String securityLevel;
  final int rssiThreshold;
  final void Function(String?) onClassChanged;
  final void Function(String?) onSubjectChanged;
  final void Function(int) onDurationChanged;
  final void Function(String) onSecurityLevelChanged;
  final void Function(int) onRssiThresholdChanged;

  const SessionConfigWidget({
    super.key,
    required this.classes,
    required this.subjects,
    required this.assignments,
    required this.selectedClassId,
    required this.selectedSubjectId,
    required this.durationSeconds,
    required this.securityLevel,
    required this.rssiThreshold,
    required this.onClassChanged,
    required this.onSubjectChanged,
    required this.onDurationChanged,
    required this.onSecurityLevelChanged,
    required this.onRssiThresholdChanged,
  });

  // Filter classes and subjects based on teacher assignments
  List<ClassModel> get _assignedClasses {
    if (assignments.isEmpty) return classes;
    final assignedClassIds = assignments.map((a) => a.classId).toSet();
    return classes.where((c) => assignedClassIds.contains(c.id)).toList();
  }

  List<SubjectModel> get _assignedSubjects {
    if (assignments.isEmpty) return subjects;
    if (selectedClassId == null) {
      final assignedSubjectIds = assignments.map((a) => a.subjectId).toSet();
      return subjects.where((s) => assignedSubjectIds.contains(s.id)).toList();
    }
    final assignedSubjectIds = assignments
        .where((a) => a.classId == selectedClassId)
        .map((a) => a.subjectId)
        .toSet();
    return subjects.where((s) => assignedSubjectIds.contains(s.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.tune_rounded,
            label: 'Session Configuration',
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            label: 'Class',
            icon: Icons.class_outlined,
            value: selectedClassId,
            items: _assignedClasses
                .map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onClassChanged,
            hint: 'Select class',
          ),
          const SizedBox(height: 14),
          _buildDropdown(
            label: 'Subject',
            icon: Icons.book_outlined,
            value: selectedSubjectId,
            items: _assignedSubjects
                .map(
                  (s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(
                      s.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onSubjectChanged,
            hint: 'Select subject',
          ),
          const SizedBox(height: 20),
          _SectionHeader(icon: Icons.timer_outlined, label: 'Duration'),
          const SizedBox(height: 12),
          Row(
            children: [15, 30, 60].map((d) {
              final isSelected = durationSeconds == d;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: d != 60 ? 8 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withAlpha(64)
                          : const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary.withAlpha(153)
                            : const Color(0x1AFFFFFF),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => onDurationChanged(d),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          '${d}s',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primary
                                : const Color(0x66FFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _SectionHeader(
            icon: Icons.security_outlined,
            label: 'Security Level',
          ),
          const SizedBox(height: 12),
          Row(
            children: ['LOW', 'HIGH'].map((level) {
              final isSelected = securityLevel == level;
              final color = level == 'HIGH'
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFF59E0B);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: level == 'LOW' ? 8 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withAlpha(38)
                          : const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? color.withAlpha(128)
                            : const Color(0x1AFFFFFF),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => onSecurityLevelChanged(level),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            level == 'HIGH'
                                ? Icons.bluetooth_searching_rounded
                                : Icons.pin_outlined,
                            color: isSelected ? color : const Color(0x66FFFFFF),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? color
                                  : const Color(0x66FFFFFF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (securityLevel == 'HIGH') ...[
            const SizedBox(height: 20),
            _SectionHeader(
              icon: Icons.signal_cellular_alt_rounded,
              label: 'RSSI Threshold: $rssiThreshold dBm',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '-100',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0x66FFFFFF),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.primary,
                      inactiveTrackColor: const Color(0x1AFFFFFF),
                      thumbColor: AppTheme.primary,
                      overlayColor: AppTheme.primary.withAlpha(38),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                    ),
                    child: Slider(
                      value: rssiThreshold.toDouble(),
                      min: -100,
                      max: -30,
                      divisions: 70,
                      onChanged: (v) => onRssiThresholdChanged(v.toInt()),
                    ),
                  ),
                ),
                Text(
                  '-30',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0x66FFFFFF),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Far',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: const Color(0x66FFFFFF),
                    ),
                  ),
                  Text(
                    'Close',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: const Color(0x66FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0x66FFFFFF),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x26FFFFFF), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  hint,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0x33FFFFFF),
                  ),
                ),
              ),
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A3A),
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0x66FFFFFF),
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0x99FFFFFF)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0x99FFFFFF),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// Import AppTheme for color reference
