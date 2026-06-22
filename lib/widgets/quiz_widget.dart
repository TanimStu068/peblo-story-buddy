// Renders the quiz from QuizModel — NEVER hardcoded.
// Handles: wrong answer shake, correct answer success state.
// Options list is generated dynamically — works for 3, 4, or 5 options.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../utils/app_constants.dart';

class QuizWidget extends StatefulWidget {
  const QuizWidget({super.key});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnimation;

  // Track previous quiz state to detect wrong-answer events
  QuizState _lastState = QuizState.visible;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: AppConstants.shakeAnimDuration,
    );
    _shakeAnimation = _ShakeTween().animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeCtrl.forward(from: 0);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryProvider>(
      builder: (context, provider, _) {
        // Detect state transitions for shake trigger
        if (provider.quizState == QuizState.wrong &&
            _lastState != QuizState.wrong) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _triggerShake());
        }
        _lastState = provider.quizState;

        if (!provider.isQuizVisible) return const SizedBox.shrink();

        return AnimatedOpacity(
          duration: AppConstants.quizRevealDuration,
          opacity: provider.isQuizVisible ? 1.0 : 0.0,
          child: AnimatedSlide(
            duration: AppConstants.quizRevealDuration,
            offset: provider.isQuizVisible ? Offset.zero : const Offset(0, 0.2),
            curve: Curves.easeOutCubic,
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: provider.quizState == QuizState.correct
                  ? _SuccessPanel(answer: provider.quizModel.answer)
                  : _QuizPanel(
                      model: provider.quizModel,
                      selectedOption: provider.selectedOption,
                      quizState: provider.quizState,
                    ),
            ),
          ),
        );
      },
    );
  }
}

// ── Question panel ────────────────────────────────────────────────────────────

class _QuizPanel extends StatelessWidget {
  final dynamic model; // QuizModel
  final String? selectedOption;
  final QuizState quizState;

  const _QuizPanel({
    required this.model,
    required this.selectedOption,
    required this.quizState,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StoryProvider>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F0FF), Color(0xFFEDE7FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🧠 Quiz Time!',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (quizState == QuizState.wrong) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '❌ Try again!',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Question text — from JSON, not hardcoded
          Text(
            model.question,
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Options — dynamically generated from model.options list
          // Works for 3, 4, or 5 options without any code change
          ...List.generate(model.options.length, (index) {
            final option = model.options[index] as String;
            final colorIndex = index % AppColors.optionColors.length;
            final isWrongSelected =
                quizState == QuizState.wrong && option == selectedOption;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionButton(
                option: option,
                bgColor: isWrongSelected
                    ? AppColors.errorLight
                    : AppColors.optionColors[colorIndex],
                borderColor: isWrongSelected
                    ? AppColors.error
                    : AppColors.optionBorderColors[colorIndex],
                isWrong: isWrongSelected,
                onTap: () => provider.selectOption(option),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionButton extends StatefulWidget {
  final String option;
  final Color bgColor;
  final Color borderColor;
  final bool isWrong;
  final VoidCallback onTap;

  const _OptionButton({
    required this.option,
    required this.bgColor,
    required this.borderColor,
    required this.isWrong,
    required this.onTap,
  });

  @override
  State<_OptionButton> createState() => _OptionButtonState();
}

class _OptionButtonState extends State<_OptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.95).animate(_pressCtrl);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pressAnim,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isWrong ? AppColors.error : widget.borderColor,
              width: widget.isWrong ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: widget.isWrong
                      ? AppColors.error
                      : widget.borderColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: widget.isWrong
                      ? const Icon(Icons.close, size: 16, color: Colors.white)
                      : Text(
                          '●',
                          style: TextStyle(
                            color: widget.borderColor,
                            fontSize: 10,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.option,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: widget.isWrong
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Success panel ─────────────────────────────────────────────────────────────

class _SuccessPanel extends StatefulWidget {
  final String answer;
  const _SuccessPanel({required this.answer});

  @override
  State<_SuccessPanel> createState() => _SuccessPanelState();
}

class _SuccessPanelState extends State<_SuccessPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.success, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              Text(
                'Amazing!',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "That's right! The gear was",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  widget.answer,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You\'re a super reader! ⭐',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Custom shake tween ────────────────────────────────────────────────────────

class _ShakeTween extends Tween<double> {
  _ShakeTween() : super(begin: 0, end: 0);

  @override
  double lerp(double t) {
    // Oscillate left–right, decaying over time
    return math.sin(t * math.pi * 6) * 12 * (1 - t);
  }
}
