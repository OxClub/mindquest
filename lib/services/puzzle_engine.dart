import 'dart:math';
import '../models/puzzle.dart';

class PuzzleEngine {
  static String dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  static int seedForDate(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static List<Puzzle> dailyFor(DateTime date) {
    final random = Random(seedForDate(DateTime(date.year, date.month, date.day)));
    final categories = PuzzleCategory.values.toList()..shuffle(random);
    return List.generate(5, (i) => generate(categories[i], (i % 3) + 1, random, '$i'));
  }

  static Puzzle practice(PuzzleCategory category, int difficulty) =>
      generate(category, difficulty, Random(DateTime.now().microsecondsSinceEpoch), 'practice-${DateTime.now().microsecondsSinceEpoch}');

  static Puzzle generate(PuzzleCategory type, int difficulty, Random random, String key) {
    switch (type) {
      case PuzzleCategory.pattern:
        final start = random.nextInt(8) + 2, step = random.nextInt(6) + difficulty;
        final sequence = List.generate(4, (i) => start + step * i);
        final answer = '${start + step * 4}';
        return _choice('$key-pattern', type, difficulty, 'Next in line', '${sequence.join('  •  ')}  •  ?', answer,
          _numbers(answer, random), 'The pattern adds $step each time.', ['Find the change between neighbors.', 'Add $step to ${sequence.last}.']);
      case PuzzleCategory.logic:
        final items = ['Ava', 'Bo', 'Cy'];
        items.shuffle(random);
        final answer = items[1];
        return _choice('$key-logic', type, difficulty, 'Order detective', '${items[0]} is first. ${items[2]} is last. Who is in the middle?', answer,
          _shuffled(items, random), 'With one person first and one last, $answer is the only middle position.', ['Place the named first and last people.', 'Only one name remains.']);
      case PuzzleCategory.memory:
        final cells = <int>{}; while (cells.length < (difficulty + 2)) { cells.add(random.nextInt(9)); }
        final pattern = cells.toList()..sort();
        return Puzzle(id: '$key-memory', category: type, difficulty: difficulty, title: 'Spark recall',
          prompt: 'Memorise the glowing tiles, then tap the same tiles.', options: const [], answer: pattern.join(','),
          explanation: 'The target tiles were ${pattern.map((n) => n + 1).join(', ')}.', hints: ['Use the tile positions as a small picture.', 'There are ${pattern.length} glowing tiles.'],
          answerStyle: AnswerStyle.memoryGrid, memoryPattern: pattern);
      case PuzzleCategory.word:
        const words = [('PLANET', 'PLANET'), ('SILENT', 'SILENT'), ('GARDEN', 'GARDEN')];
        final pair = words[random.nextInt(words.length)]; final scrambled = _scramble(pair.$1, random);
        return _choice('$key-word', type, difficulty, 'Letter weave', 'Unscramble:  $scrambled', pair.$2,
          _shuffled([pair.$2, 'PLATE', 'LISTEN', 'DANGER'], random), 'Rearranging the letters spells ${pair.$2}.', ['Look for familiar word endings.', 'The answer is a common noun or adjective.']);
      case PuzzleCategory.math:
        final a = random.nextInt(12) + 4, b = random.nextInt(8) + 2;
        final answer = '${a * b}';
        return _choice('$key-math', type, difficulty, 'Quick calculation', '$a × $b = ?', answer,
          _numbers(answer, random), '$a groups of $b equal $answer.', ['Break one factor into smaller groups.', '$a × $b = $answer.']);
      case PuzzleCategory.spatial:
        final answer = random.nextBool() ? 'Mirror' : 'Rotation';
        return _choice('$key-spatial', type, difficulty, 'Shape sense', 'A triangle turns 90° clockwise. What changed?', answer,
          _shuffled(['Mirror', 'Rotation', 'Size', 'Number of sides'], random), 'Turning a shape changes its rotation, not its size or sides.', ['Imagine rotating a paper triangle.', 'A reflection would reverse left and right.']);
    }
  }

  static Puzzle _choice(String id, PuzzleCategory category, int difficulty, String title, String prompt, String answer, List<String> options, String explanation, List<String> hints) =>
      Puzzle(id: id, category: category, difficulty: difficulty, title: title, prompt: prompt, options: options, answer: answer, explanation: explanation, hints: hints);
  static List<String> _numbers(String answer, Random random) {
    final n = int.parse(answer); return _shuffled(['$n', '${n + 2}', '${max(1, n - 3)}', '${n + 5}'], random);
  }
  static List<String> _shuffled(List<String> values, Random r) => values.toSet().toList()..shuffle(r);
  static String _scramble(String text, Random r) { final v = text.split('')..shuffle(r); return v.join(); }
}

class Score {
  static int points({required int difficulty, required bool hintUsed, int secondsLeft = 0}) {
    final base = 20 + (difficulty * 15);
    return max(10, base + min(15, secondsLeft ~/ 4) - (hintUsed ? 10 : 0));
  }
}
