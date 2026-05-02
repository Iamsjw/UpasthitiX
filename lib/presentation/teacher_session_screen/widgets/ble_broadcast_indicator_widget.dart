import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class BleBroadcastIndicatorWidget extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final String sessionId;
  final bool isAdvertising;

  const BleBroadcastIndicatorWidget({
    super.key,
    required this.pulseAnimation,
    required this.sessionId,
    required this.isAdvertising,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isAdvertising
                ? const Color(0x1A6C63FF)
                : const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isAdvertising
                  ? AppTheme.primary.withAlpha(102)
                  : const Color(0x1AFFFFFF),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Animated BLE pulse rings
              AnimatedBuilder(
                animation: pulseAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        if (isAdvertising)
                          Transform.scale(
                            scale: pulseAnimation.value * 1.4,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(
                                    (1 - pulseAnimation.value) * 0.4,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        // Middle ring
                        if (isAdvertising)
                          Transform.scale(
                            scale: pulseAnimation.value * 1.1,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primary.withOpacity(
                                    (1 - pulseAnimation.value) * 0.5,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        // Core
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAdvertising
                                ? AppTheme.primary.withAlpha(51)
                                : const Color(0x0DFFFFFF),
                            border: Border.all(
                              color: isAdvertising
                                  ? AppTheme.primary.withAlpha(153)
                                  : const Color(0x26FFFFFF),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.bluetooth_rounded,
                            color: isAdvertising
                                ? AppTheme.primary
                                : const Color(0x66FFFFFF),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isAdvertising ? 'BLE Broadcasting' : 'BLE Inactive',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isAdvertising
                                ? const Color(0x3322C55E)
                                : const Color(0x14FFFFFF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAdvertising ? 'ACTIVE' : 'OFF',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isAdvertising
                                  ? const Color(0xFF22C55E)
                                  : const Color(0x66FFFFFF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAdvertising
                          ? 'Students within range can detect this session'
                          : 'BLE advertising not started',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0x66FFFFFF),
                      ),
                    ),
                    if (isAdvertising) ...[
                      const SizedBox(height: 6),
                      Text(
                        'ID: ${sessionId.substring(0, 8).toUpperCase()}...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary.withAlpha(204),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
