// Manages audio playback state and quiz state via Provider.
// Keeps the widget tree lean — no logic leaks into widgets.

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_model.dart';
import '../utils/app_constants.dart';

/// All possible audio/TTS states.
enum AudioState {
  idle, // Not started yet
  loading, // TTS engine initialising
  playing, // Speech in progress
  finished, // Playback complete → quiz should appear
  error, // Something went wrong
}

/// All possible quiz states.
enum QuizState {
  hidden, // Before audio finishes
  visible, // Quiz showing, no answer selected
  wrong, // Wrong answer chosen — shake & retry
  correct, // Correct answer chosen — celebrate!
}

class StoryProvider extends ChangeNotifier {
  // ── TTS ──────────────────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();
  AudioState _audioState = AudioState.idle;
  String _errorMessage = '';

  AudioState get audioState => _audioState;
  String get errorMessage => _errorMessage;

  // ── Quiz ─────────────────────────────────────────────────────────────
  // Load from JSON once; never hardcoded.
  late final QuizModel quizModel = QuizModel.fromJson(AppConstants.quizJson);

  QuizState _quizState = QuizState.hidden;
  String? _selectedOption;

  QuizState get quizState => _quizState;
  String? get selectedOption => _selectedOption;

  bool get isQuizVisible => _quizState != QuizState.hidden;

  // ── Init ─────────────────────────────────────────────────────────────
  StoryProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    // Configure TTS callbacks ONCE. Safe to call multiple times;
    // flutter_tts is idempotent for handler registration.
    await _tts.setLanguage('en-IN'); // Indian English accent
    await _tts.setSpeechRate(AppConstants.ttsRate);
    await _tts.setPitch(AppConstants.ttsPitch);
    await _tts.setVolume(AppConstants.ttsVolume);

    _tts.setStartHandler(() {
      _audioState = AudioState.playing;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      _audioState = AudioState.finished;
      _quizState = QuizState.visible; // Reveal quiz on completion
      notifyListeners();
    });

    _tts.setErrorHandler((message) {
      _audioState = AudioState.error;
      _errorMessage = message?.toString() ?? 'TTS failed. Please try again.';
      notifyListeners();
    });

    _tts.setCancelHandler(() {
      // Treat cancel (e.g. another app interrupting) as idle
      if (_audioState == AudioState.playing) {
        _audioState = AudioState.idle;
        notifyListeners();
      }
    });
  }

  // ── Public actions ────────────────────────────────────────────────────

  /// Called when the user taps "Read Me a Story".
  Future<void> startNarration() async {
    if (_audioState == AudioState.playing) return;

    _audioState = AudioState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      // Check TTS engine availability
      final available = await _tts.getLanguages;
      if (available == null || (available as List).isEmpty) {
        throw Exception('TTS engine not available on this device.');
      }

      await _tts.speak(AppConstants.storyText);
      // setStartHandler fires → sets AudioState.playing
    } catch (e) {
      _audioState = AudioState.error;
      _errorMessage = 'Oops! Could not start the story. Please try again.';
      notifyListeners();
    }
  }

  /// Stop any ongoing TTS (e.g. if user navigates away).
  Future<void> stopNarration() async {
    await _tts.stop();
    _audioState = AudioState.idle;
    notifyListeners();
  }

  /// Called when the child selects a quiz option.
  void selectOption(String option) {
    if (_quizState == QuizState.correct) return; // Already won, ignore taps

    _selectedOption = option;

    if (option == quizModel.answer) {
      _quizState = QuizState.correct;
    } else {
      _quizState = QuizState.wrong;
      // Reset to visible after shake animation so child can try again
      Future.delayed(AppConstants.shakeAnimDuration, () {
        if (_quizState == QuizState.wrong) {
          _quizState = QuizState.visible;
          _selectedOption = null;
          notifyListeners();
        }
      });
    }
    notifyListeners();
  }

  /// Reset the whole experience (replay button).
  Future<void> reset() async {
    await _tts.stop();
    _audioState = AudioState.idle;
    _quizState = QuizState.hidden;
    _selectedOption = null;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
