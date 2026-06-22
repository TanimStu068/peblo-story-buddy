import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../widgets/buddy_widget.dart';
import '../widgets/story_card.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/background_painter.dart';
import '../utils/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Animated background decorations ────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => CustomPaint(
              painter: BackgroundPainter(_bgController.value),
              child: const SizedBox.expand(),
            ),
          ),

          // ── Main content ────────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Header
                        _Header(),

                        const SizedBox(height: 8),

                        // Buddy character — only rebuilds when audio/quiz state changes
                        Selector<
                          StoryProvider,
                          ({AudioState audio, QuizState quiz})
                        >(
                          selector: (_, p) =>
                              (audio: p.audioState, quiz: p.quizState),
                          builder: (_, states, __) => BuddyWidget(
                            audioState: states.audio,
                            quizState: states.quiz,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Story card with TTS button
                        const StoryCard(),

                        const SizedBox(height: 20),

                        // Quiz — revealed after narration completes
                        const QuizWidget(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Confetti — only appears on correct answer ───────────────
          Selector<StoryProvider, QuizState>(
            selector: (_, p) => p.quizState,
            builder: (_, quizState, __) =>
                ConfettiOverlay(quizState: quizState),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Story Buddy 🤖',
              style: GoogleFonts.nunito(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Powered by Peblo ✨',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        // Replay button (always accessible)
        Selector<StoryProvider, AudioState>(
          selector: (_, p) => p.audioState,
          builder: (_, audioState, __) {
            if (audioState == AudioState.idle) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.refresh_rounded),
              color: AppColors.secondary,
              tooltip: 'Start Over',
              onPressed: () => context.read<StoryProvider>().reset(),
            );
          },
        ),
      ],
    );
  }
}
