import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassFormFieldWidget extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;

  const GlassFormFieldWidget({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<GlassFormFieldWidget> createState() => _GlassFormFieldWidgetState();
}

class _GlassFormFieldWidgetState extends State<GlassFormFieldWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOutCubic),
    );
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF6C63FF,
                ).withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                validator: widget.validator,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: _isFocused
                      ? const Color(0x1AFFFFFF)
                      : const Color(0x0DFFFFFF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0x26FFFFFF),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0x26FFFFFF),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C63FF),
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  labelStyle: const TextStyle(
                    color: Color(0x66FFFFFF),
                    fontSize: 14,
                  ),
                  hintStyle: const TextStyle(
                    color: Color(0x33FFFFFF),
                    fontSize: 14,
                  ),
                  errorStyle: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 11,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
