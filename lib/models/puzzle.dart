enum PuzzleCategory { pattern, logic, memory, word, math, spatial }

extension PuzzleCategoryX on PuzzleCategory {
  String get label => switch (this) {
        PuzzleCategory.pattern => 'Pattern',
        PuzzleCategory.logic => 'Logic',
        PuzzleCategory.memory => 'Memory',
        PuzzleCategory.word => 'Words',
        PuzzleCategory.math => 'Math',
        PuzzleCategory.spatial => 'Spatial',
      };

  String get icon => switch (this) {
        PuzzleCategory.pattern => '◌', PuzzleCategory.logic => '⌘',
        PuzzleCategory.memory => '◈', PuzzleCategory.word => 'Aa',
        PuzzleCategory.math => '±', PuzzleCategory.spatial => '◇',
      };
}

enum AnswerStyle { choice, text, memoryGrid }

class Puzzle {
  const Puzzle({
    required this.id, required this.category, required this.difficulty,
    required this.title, required this.prompt, required this.options,
    required this.answer, required this.explanation, required this.hints,
    this.answerStyle = AnswerStyle.choice, this.memoryPattern = const [],
  });

  final String id;
  final PuzzleCategory category;
  final int difficulty;
  final String title;
  final String prompt;
  final List<String> options;
  final String answer;
  final String explanation;
  final List<String> hints;
  final AnswerStyle answerStyle;
  final List<int> memoryPattern;

  bool matches(String value) => value.trim().toLowerCase() == answer.toLowerCase();
}
