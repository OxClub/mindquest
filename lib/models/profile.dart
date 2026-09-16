import 'dart:convert';

class Profile {
  Profile({
    this.onboarded = false, this.difficulty = 2, this.points = 0,
    this.totalAttempted = 0, this.totalSolved = 0, this.streak = 0,
    this.longestStreak = 0, this.lastDailyDate, Map<String, dynamic>? daily,
    Map<String, dynamic>? categories, List<String>? achievements,
    this.themeMode = 'system', this.sound = true, this.haptics = true,
    this.reducedMotion = false,
  })  : daily = daily ?? {}, categories = categories ?? {},
        achievements = achievements ?? [];

  bool onboarded;
  int difficulty;
  int points;
  int totalAttempted;
  int totalSolved;
  int streak;
  int longestStreak;
  String? lastDailyDate;
  Map<String, dynamic> daily;
  Map<String, dynamic> categories;
  List<String> achievements;
  String themeMode;
  bool sound;
  bool haptics;
  bool reducedMotion;

  int get level => (points ~/ 250) + 1;
  int get levelProgress => points % 250;
  int get accuracy => totalAttempted == 0 ? 0 : ((totalSolved / totalAttempted) * 100).round();

  Map<String, dynamic> toMap() => {
    'onboarded': onboarded, 'difficulty': difficulty, 'points': points,
    'totalAttempted': totalAttempted, 'totalSolved': totalSolved,
    'streak': streak, 'longestStreak': longestStreak, 'lastDailyDate': lastDailyDate,
    'daily': daily, 'categories': categories, 'achievements': achievements,
    'themeMode': themeMode, 'sound': sound, 'haptics': haptics,
    'reducedMotion': reducedMotion,
  };

  factory Profile.fromJson(String value) {
    try {
      final m = jsonDecode(value) as Map<String, dynamic>;
      return Profile(
        onboarded: m['onboarded'] == true, difficulty: m['difficulty'] ?? 2,
        points: m['points'] ?? 0, totalAttempted: m['totalAttempted'] ?? 0,
        totalSolved: m['totalSolved'] ?? 0, streak: m['streak'] ?? 0,
        longestStreak: m['longestStreak'] ?? 0, lastDailyDate: m['lastDailyDate'],
        daily: Map<String, dynamic>.from(m['daily'] ?? {}),
        categories: Map<String, dynamic>.from(m['categories'] ?? {}),
        achievements: List<String>.from(m['achievements'] ?? []),
        themeMode: m['themeMode'] ?? 'system', sound: m['sound'] ?? true,
        haptics: m['haptics'] ?? true, reducedMotion: m['reducedMotion'] ?? false,
      );
    } catch (_) { return Profile(); }
  }
  String toJson() => jsonEncode(toMap());
}
