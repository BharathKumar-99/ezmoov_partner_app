import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final dynamic Function()? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Gradient gradient;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isInternalLoading = false;

  Future<void> _handleTap() async {
    if (widget.onPressed == null || widget.isLoading || _isInternalLoading) return;
    FocusManager.instance.primaryFocus?.unfocus();

    if (mounted) {
      setState(() {
        _isInternalLoading = true;
      });
    }

    try {
      final dynamic result = widget.onPressed!();
      if (result is Future) {
        await result;
      }
    } catch (e) {
      debugPrint('Notice in GradientButton execution: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInternalLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLoading = widget.isLoading || _isInternalLoading;
    final isEnabled = widget.onPressed != null && !effectiveLoading;

    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: isEnabled || effectiveLoading ? widget.gradient : null,
        color: !isEnabled && !effectiveLoading ? AppColors.border : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isEnabled || effectiveLoading
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _handleTap : null,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withValues(alpha: 0.25),
          highlightColor: Colors.white.withValues(alpha: 0.15),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: effectiveLoading
                  ? const SizedBox(
                      key: ValueKey('loading_indicator'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      key: const ValueKey('button_content'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
