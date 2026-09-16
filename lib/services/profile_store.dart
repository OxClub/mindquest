import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile.dart';
import '../models/puzzle.dart';
import 'puzzle_engine.dart';

class ProfileStore {
  static const _key = 'mindquest_profile_v1';
  late SharedPreferences _prefs;
  late Profile profile;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    profile = Profile.fromJson(_prefs.getString(_key) ?? '');
  }
  Future<void> save() => _prefs.setString(_key, profile.toJson());
  Future<void> reset() async { profile = Profile(); await save(); }

  Map<String, dynamic> today(DateTime now) {
    final key = PuzzleEngine.dateKey(now);
    return Map<String, dynamic>.from(profile.daily[key] ?? {'solved': <String>[], 'answered': <String>[], 'points': 0});
  }
  bool isSolvedToday(DateTime now, String id) => List<String>.from(today(now)['solved'] ?? []).contains(id);

  Future<List<String>> recordAnswer(Puzzle puzzle, bool correct, {bool daily = false, bool hintUsed = false}) async {
    final alreadySolved = daily && isSolvedToday(DateTime.now(), puzzle.id);
    profile.totalAttempted++;
    final key = puzzle.category.name;
    final stats = Map<String, dynamic>.from(profile.categories[key] ?? {'attempted': 0, 'solved': 0});
    stats['attempted'] = (stats['attempted'] ?? 0) + 1;
    // Reopening a solved daily card must not inflate solved statistics.
    if (correct && !alreadySolved) { profile.totalSolved++; stats['solved'] = (stats['solved'] ?? 0) + 1; }
    profile.categories[key] = stats;
    if (daily) {
      final date = PuzzleEngine.dateKey(DateTime.now()); final state = today(DateTime.now());
      final answered = List<String>.from(state['answered'] ?? []);
      if (!answered.contains(puzzle.id)) answered.add(puzzle.id);
      state['answered'] = answered;
      if (correct) {
        final solved = List<String>.from(state['solved'] ?? []);
        if (!solved.contains(puzzle.id)) { solved.add(puzzle.id); final gained = Score.points(difficulty: puzzle.difficulty, hintUsed: hintUsed); state['points'] = (state['points'] ?? 0) + gained; profile.points += gained; }
        state['solved'] = solved;
      }
      profile.daily[date] = state;
      if (List<String>.from(state['solved'] ?? []).length >= 5) _completeDaily(date);
    } else if (correct) { profile.points += Score.points(difficulty: puzzle.difficulty, hintUsed: hintUsed); }
    final unlocked = _unlock(); await save(); return unlocked;
  }

  void _completeDaily(String date) {
    if (profile.lastDailyDate == date) return;
    final day = DateTime.parse(date); final previous = PuzzleEngine.dateKey(day.subtract(const Duration(days: 1)));
    profile.streak = profile.lastDailyDate == previous ? profile.streak + 1 : 1;
    profile.longestStreak = profile.streak > profile.longestStreak ? profile.streak : profile.longestStreak;
    profile.lastDailyDate = date;
  }
  List<String> _unlock() {
    final allCategories = PuzzleCategory.values.every((c) => (profile.categories[c.name]?['attempted'] ?? 0) > 0);
    final options = <String, bool>{
      'First Spark': profile.totalSolved >= 1,
      'Daily Orbit': profile.lastDailyDate != null,
      'Three Day Current': profile.streak >= 3,
      'Puzzle Cartographer': allCategories,
      'Precision Pulse': profile.totalAttempted >= 10 && profile.accuracy >= 80,
      'Point Voyager': profile.points >= 100,
    };
    final added = <String>[]; options.forEach((name, earned) { if (earned && !profile.achievements.contains(name)) { profile.achievements.add(name); added.add(name); } });
    return added;
  }
}
