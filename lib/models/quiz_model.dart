// Data model for the quiz — fully driven by JSON, never hardcoded.
// Supports 3, 4, or 5 options without any code changes.

class QuizModel {
  final String question;
  final List<String> options;
  final String answer;

  const QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  /// Parse from a JSON map (as if received from the backend).
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'answer': answer,
  };
}
