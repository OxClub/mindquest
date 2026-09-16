import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindquest/models/puzzle.dart';
import 'package:mindquest/services/puzzle_engine.dart';

void main() {
  group('daily puzzle engine', () {
    test('is deterministic for one local calendar date', () {
      final date = DateTime(2026, 9, 16);
      final first = PuzzleEngine.dailyFor(date);
      final again = PuzzleEngine.dailyFor(date);
      expect(first.map((p) => p.id), again.map((p) => p.id));
      expect(first.map((p) => p.answer), again.map((p) => p.answer));
    });
    test('has five distinct categories and ids', () {
      final puzzles = PuzzleEngine.dailyFor(DateTime(2026, 4, 9));
      expect(puzzles, hasLength(5));
      expect(puzzles.map((p) => p.id).toSet(), hasLength(5));
      expect(puzzles.map((p) => p.category).toSet(), hasLength(5));
    });
    test('generated answer always validates', () {
      for (final category in PuzzleCategory.values) {
        final puzzle = PuzzleEngine.generate(category, 2, Random(42), 'test');
        expect(puzzle.matches(puzzle.answer), isTrue);
        expect(puzzle.explanation, isNotEmpty);
      }
    });
  });
  group('scoring', () {
    test('difficulty increases score and hint reduces it', () {
      expect(Score.points(difficulty: 3, hintUsed: false), greaterThan(Score.points(difficulty: 1, hintUsed: false)));
      expect(Score.points(difficulty: 2, hintUsed: true), lessThan(Score.points(difficulty: 2, hintUsed: false)));
    });
  });
}
