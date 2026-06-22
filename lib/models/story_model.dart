class StoryModel {
  final String id;
  final String title;
  final String text;
  final QuizData quiz;

  const StoryModel({
    required this.id,
    required this.title,
    required this.text,
    required this.quiz,
  });
}

class QuizData {
  final String question;
  final List<String> options;
  final String answer;

  const QuizData({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) => QuizData(
    question: json['question'] as String,
    options: List<String>.from(json['options'] as List),
    answer: json['answer'] as String,
  );
}
