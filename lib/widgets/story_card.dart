// Displays story text and the "Read Me a Story" button.
// Handles all audio states: idle, loading, playing, finished, error.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../utils/app_constants.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Story title
              Row(
                children: [
                  const Text('📖', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    AppConstants.storyTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Story text
              Text(
                AppConstants.storyText,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 24),

              // Error message (if any)
              if (provider.audioState == AudioState.error) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // CTA Button
              _NarrationButton(audioState: provider.audioState),
            ],
          ),
        );
      },
    );
  }
}

class _NarrationButton extends StatelessWidget {
  final AudioState audioState;

  const _NarrationButton({required this.audioState});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StoryProvider>();

    final bool isLoading = audioState == AudioState.loading;
    final bool isPlaying = audioState == AudioState.playing;
    final bool isFinished = audioState == AudioState.finished;
    final bool isError = audioState == AudioState.error;

    String label;
    IconData icon;
    Color bgColor;

    if (isLoading) {
      label = 'Getting ready...';
      icon = Icons.hourglass_top_rounded;
      bgColor = AppColors.secondary;
    } else if (isPlaying) {
      label = 'Listening...';
      icon = Icons.volume_up_rounded;
      bgColor = AppColors.primary;
    } else if (isFinished) {
      label = 'Read Again ✨';
      icon = Icons.replay_rounded;
      bgColor = AppColors.primaryLight;
    } else if (isError) {
      label = 'Try Again!';
      icon = Icons.refresh_rounded;
      bgColor = AppColors.error;
    } else {
      label = 'Read Me a Story!';
      icon = Icons.play_circle_fill_rounded;
      bgColor = AppColors.primary;
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ElevatedButton.icon(
          onPressed: (isLoading || isPlaying)
              ? null
              : () {
                  if (isFinished || isError) {
                    provider.reset();
                  } else {
                    provider.startNarration();
                  }
                },
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : _PulsingIcon(icon: icon, isPlaying: isPlaying),
          label: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: bgColor.withOpacity(0.7),
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isPlaying ? 0 : 4,
          ),
        ),
      ),
    );
  }
}

/// Pulses while audio is playing to give a visual speaking indicator.
class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final bool isPlaying;

  const _PulsingIcon({required this.icon, required this.isPlaying});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isPlaying) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingIcon old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isPlaying && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: Icon(widget.icon, size: 22));
  }
}
