import 'package:flutter/material.dart';
import 'models/profile.dart';
import 'models/puzzle.dart';
import 'services/profile_store.dart';
import 'services/puzzle_engine.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = ProfileStore();
  await store.load();
  runApp(MindQuestApp(store: store));
}

class MindQuestApp extends StatefulWidget {
  const MindQuestApp({super.key, required this.store});
  final ProfileStore store;
  @override State<MindQuestApp> createState() => _MindQuestAppState();
}

class _MindQuestAppState extends State<MindQuestApp> {
  ThemeMode get _mode => switch (widget.store.profile.themeMode) { 'light' => ThemeMode.light, 'dark' => ThemeMode.dark, _ => ThemeMode.system };
  void _refresh() => setState(() {});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'MindQuest', debugShowCheckedModeBanner: false, themeMode: _mode,
    theme: _theme(Brightness.light), darkTheme: _theme(Brightness.dark),
    home: widget.store.profile.onboarded ? QuestShell(store: widget.store, refresh: _refresh) : Onboarding(store: widget.store, refresh: _refresh),
  );
}

ThemeData _theme(Brightness brightness) {
  const seed = Color(0xff5b4bdb);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness, tertiary: const Color(0xffe78752));
  return ThemeData(colorScheme: scheme, useMaterial3: true, scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(elevation: 0, color: scheme.surfaceContainerLow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: scheme.surfaceContainerHighest, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
  );
}

class Onboarding extends StatefulWidget { const Onboarding({super.key, required this.store, required this.refresh}); final ProfileStore store; final VoidCallback refresh; @override State<Onboarding> createState() => _OnboardingState(); }
class _OnboardingState extends State<Onboarding> {
  int difficulty = 2;
  Future<void> done() async { widget.store.profile.onboarded = true; widget.store.profile.difficulty = difficulty; await widget.store.save(); widget.refresh(); }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Spacer(), Center(child: Container(width: 118, height: 118, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle), child: const Icon(Icons.psychology_alt_rounded, size: 62))),
    const SizedBox(height: 32), Text('Welcome to\nMindQuest', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 12), Text('A small daily expedition for your memory, logic, words and more. Five puzzles. Your pace. Entirely offline.', style: Theme.of(context).textTheme.titleMedium),
    const SizedBox(height: 34), Text('Choose your starting pace', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    const SizedBox(height: 12), SegmentedButton<int>(segments: const [ButtonSegment(value: 1,label: Text('Gentle')), ButtonSegment(value: 2,label: Text('Balanced')), ButtonSegment(value: 3,label: Text('Bold'))], selected: {difficulty}, onSelectionChanged: (v) => setState(() => difficulty = v.first)),
    const Spacer(), FilledButton(onPressed: done, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)), child: const Text('Begin today’s quest')), TextButton(onPressed: done, child: const Center(child: Text('Skip for now'))),
  ]))));
}

class QuestShell extends StatefulWidget { const QuestShell({super.key, required this.store, required this.refresh}); final ProfileStore store; final VoidCallback refresh; @override State<QuestShell> createState() => _QuestShellState(); }
class _QuestShellState extends State<QuestShell> {
  int tab = 0; void changed() { setState(() {}); widget.refresh(); }
  @override Widget build(BuildContext context) { final pages = [HomeTab(store: widget.store, changed: changed), PracticeTab(store: widget.store, changed: changed), ProgressTab(store: widget.store), SettingsTab(store: widget.store, changed: changed)];
    return Scaffold(body: SafeArea(child: pages[tab]), bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Quest'), NavigationDestination(icon: Icon(Icons.extension_outlined), selectedIcon: Icon(Icons.extension), label: 'Practice'), NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progress'), NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings')])); }
}

class HomeTab extends StatelessWidget { const HomeTab({super.key, required this.store, required this.changed}); final ProfileStore store; final VoidCallback changed;
  @override Widget build(BuildContext context) { final p = store.profile; final state = store.today(DateTime.now()); final complete = List<String>.from(state['solved'] ?? []).length; final message = complete == 5 ? 'The day is yours. Lovely work.' : complete > 0 ? 'Nice momentum. Keep exploring.' : 'A fresh puzzle trail is waiting.';
    return ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 32), children: [Row(children: [const _Logo(), const SizedBox(width: 10), Text('MindQuest', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const Spacer(), Semantics(label: 'Current level ${p.level}', child: Chip(avatar: const Icon(Icons.auto_awesome, size: 18), label: Text('Lv. ${p.level}')))]), const SizedBox(height: 25), Text('Good ${_greeting()}, explorer.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)), Text(message, style: Theme.of(context).textTheme.bodyLarge), const SizedBox(height: 22), InkWell(borderRadius: BorderRadius.circular(28), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DailyScreen(store: store, changed: changed))), child: Ink(decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, const Color(0xff8678ff)]), borderRadius: BorderRadius.circular(28)), padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.wb_sunny_outlined, color: Colors.white), SizedBox(width: 8), Text('TODAY’S QUEST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2))]), const SizedBox(height: 18), Text(complete == 5 ? 'Quest complete!' : '$complete of 5 discoveries', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(height: 14), LinearProgressIndicator(value: complete / 5, minHeight: 9, borderRadius: BorderRadius.circular(10), color: Colors.white, backgroundColor: Colors.white30), const SizedBox(height: 16), const Text('A balanced mix of five brain challenges  →', style: TextStyle(color: Colors.white))]))), const SizedBox(height: 20), Row(children: [Expanded(child: _Metric(icon: Icons.local_fire_department_outlined, label: 'STREAK', value: '${p.streak} days', color: const Color(0xffe78752))), const SizedBox(width: 12), Expanded(child: _Metric(icon: Icons.bolt_outlined, label: 'POINTS', value: '${p.points}', color: const Color(0xff4da6a0)))]), const SizedBox(height: 24), Text('Next milestone', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.workspace_premium_outlined), SizedBox(width: 8), Text('Point Voyager', style: TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 10), Text('Earn 100 points to add this badge to your collection.'), const SizedBox(height: 10), LinearProgressIndicator(value: (p.points / 100).clamp(0, 1), borderRadius: BorderRadius.circular(8))])))]); }
  String _greeting() { final h = DateTime.now().hour; return h < 12 ? 'morning' : h < 18 ? 'afternoon' : 'evening'; }
}

class DailyScreen extends StatelessWidget { const DailyScreen({super.key, required this.store, required this.changed}); final ProfileStore store; final VoidCallback changed;
  @override Widget build(BuildContext context) {
    final puzzles = PuzzleEngine.dailyFor(DateTime.now());
    final done = store.today(DateTime.now());
    final solved = List<String>.from(done['solved'] ?? []);
    const names = ['Gentle', 'Balanced', 'Bold'];
    return Scaffold(appBar: AppBar(title: const Text('Today’s quest')), body: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Five small leaps forward', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6), const Text('Your set is created locally and remains the same all day.'), const SizedBox(height: 20),
      ...puzzles.asMap().entries.map((entry) { final puzzle = entry.value; final isDone = solved.contains(puzzle.id); return Card(child: ListTile(leading: CircleAvatar(child: Text(puzzle.category.icon)), title: Text('${entry.key + 1}. ${puzzle.title}'), subtitle: Text('${puzzle.category.label} • ${names[puzzle.difficulty - 1]}'), trailing: isDone ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.arrow_forward_ios, size: 16), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PuzzleScreen(puzzle: puzzle, store: store, daily: true, changed: changed))).then((_) => changed()))); }),
      const SizedBox(height: 12), if (solved.length == 5) _CompletionCard(store: store),
    ]));
  }
}

class PracticeTab extends StatefulWidget { const PracticeTab({super.key, required this.store, required this.changed}); final ProfileStore store; final VoidCallback changed; @override State<PracticeTab> createState() => _PracticeTabState(); }
class _PracticeTabState extends State<PracticeTab> { PuzzleCategory category = PuzzleCategory.pattern; int difficulty = 2;
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [Text('Practice studio', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Explore without changing your daily quest.'), const SizedBox(height: 24), Text('Choose a trail', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 10), Wrap(spacing: 8, runSpacing: 8, children: PuzzleCategory.values.map((c) => ChoiceChip(label: Text('${c.icon} ${c.label}'), selected: category == c, onSelected: (_) => setState(() => category = c))).toList()), const SizedBox(height: 24), SegmentedButton<int>(segments: const [ButtonSegment(value: 1,label: Text('Gentle')),ButtonSegment(value: 2,label: Text('Balanced')),ButtonSegment(value: 3,label: Text('Bold'))], selected: {difficulty}, onSelectionChanged: (v) => setState(() => difficulty = v.first)), const SizedBox(height: 28), FilledButton.icon(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)), icon: const Icon(Icons.play_arrow), label: const Text('Start a practice puzzle'), onPressed: () { final p = PuzzleEngine.practice(category, difficulty); Navigator.push(context, MaterialPageRoute(builder: (_) => PuzzleScreen(puzzle: p, store: widget.store, daily: false, changed: widget.changed))); })]); }
}

class PuzzleScreen extends StatefulWidget { const PuzzleScreen({super.key, required this.puzzle, required this.store, required this.daily, required this.changed}); final Puzzle puzzle; final ProfileStore store; final bool daily; final VoidCallback changed; @override State<PuzzleScreen> createState() => _PuzzleScreenState(); }
class _PuzzleScreenState extends State<PuzzleScreen> { String? selected; bool showingMemory = true, hint = false, submitted = false; Set<int> memory = {};
  @override void initState() { super.initState(); if (widget.puzzle.answerStyle == AnswerStyle.memoryGrid) Future.delayed(Duration(seconds: widget.store.profile.reducedMotion ? 5 : 3), () { if (mounted) setState(() => showingMemory = false); }); else { showingMemory = false; } }
  Future<void> submit() async { final value = widget.puzzle.answerStyle == AnswerStyle.memoryGrid ? (memory.toList()..sort()).join(',') : selected ?? ''; if (value.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose an answer first.'))); return; } final correct = widget.puzzle.matches(value); final unlocked = await widget.store.recordAnswer(widget.puzzle, correct, daily: widget.daily, hintUsed: hint); widget.changed(); if (!mounted) return; setState(() => submitted = true); await showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => ResultSheet(puzzle: widget.puzzle, correct: correct, daily: widget.daily, hint: hint, unlocked: unlocked)); if (mounted) Navigator.pop(context); }
  @override Widget build(BuildContext context) { final p = widget.puzzle; return Scaffold(appBar: AppBar(title: Text(widget.daily ? 'Daily quest' : 'Practice'), actions: [Padding(padding: const EdgeInsets.all(12), child: Chip(label: Text('${p.difficulty}/3')))]), body: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text('${p.category.icon}  ${p.category.label.toUpperCase()}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)), const SizedBox(height: 12), Text(p.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 18), Card(child: Padding(padding: const EdgeInsets.all(24), child: Text(p.prompt, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center))), const SizedBox(height: 18), Expanded(child: p.answerStyle == AnswerStyle.memoryGrid ? _MemoryBoard(pattern: p.memoryPattern, showing: showingMemory, selected: memory, onTap: (i) { if (!showingMemory) setState(() => memory.contains(i) ? memory.remove(i) : memory.add(i)); }) : ListView(children: p.options.map((o) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Semantics(selected: selected == o, button: true, label: 'Answer $o', child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56), alignment: Alignment.centerLeft, side: BorderSide(color: selected == o ? Theme.of(context).colorScheme.primary : Colors.transparent), backgroundColor: selected == o ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerLow), onPressed: () => setState(() => selected = o), child: Text(o))))).toList())), if (hint) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(14)), child: Text('Hint: ${p.hints.first}')), Row(children: [TextButton.icon(onPressed: hint ? null : () => setState(() => hint = true), icon: const Icon(Icons.lightbulb_outline), label: const Text('Use hint')), const Spacer(), FilledButton(onPressed: submitted ? null : submit, child: const Text('Check answer'))])])))); }
}

class _MemoryBoard extends StatelessWidget { const _MemoryBoard({required this.pattern, required this.showing, required this.selected, required this.onTap}); final List<int> pattern; final bool showing; final Set<int> selected; final ValueChanged<int> onTap;
 @override Widget build(BuildContext context) => Column(children: [Text(showing ? 'Hold the pattern in mind…' : 'Now rebuild the pattern.', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 20), Expanded(child: GridView.builder(itemCount: 9, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10), itemBuilder: (_, i) { final active = showing ? pattern.contains(i) : selected.contains(i); return Semantics(button: true, label: 'Memory tile ${i + 1}', child: InkWell(onTap: () => onTap(i), borderRadius: BorderRadius.circular(18), child: Ink(decoration: BoxDecoration(color: active ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(18)), child: active && showing ? const Icon(Icons.auto_awesome, color: Colors.white) : null))); }))]); }
}

class ResultSheet extends StatelessWidget { const ResultSheet({super.key, required this.puzzle, required this.correct, required this.daily, required this.hint, required this.unlocked}); final Puzzle puzzle; final bool correct, daily, hint; final List<String> unlocked;
 @override Widget build(BuildContext context) { final score = correct ? Score.points(difficulty: puzzle.difficulty, hintUsed: hint) : 0; return SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(correct ? Icons.check_circle : Icons.refresh, size: 68, color: correct ? Colors.green : Theme.of(context).colorScheme.primary), const SizedBox(height: 12), Text(correct ? 'Great thinking!' : 'Not quite this time', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text(puzzle.explanation, textAlign: TextAlign.center), if (correct) Padding(padding: const EdgeInsets.only(top: 16), child: Chip(label: Text('+$score points'))), if (unlocked.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text('Unlocked: ${unlocked.join(', ')}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))), const SizedBox(height: 20), FilledButton(onPressed: () => Navigator.pop(context), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: Text(daily ? 'Back to today’s quest' : 'Try another'))]))); }
}

class ProgressTab extends StatelessWidget { const ProgressTab({super.key, required this.store}); final ProfileStore store;
 @override Widget build(BuildContext context) { final p = store.profile; return ListView(padding: const EdgeInsets.all(20), children: [Text('Your signals', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 20), Row(children: [Expanded(child: _Metric(icon: Icons.check_circle_outline,label: 'SOLVED',value: '${p.totalSolved}',color: Colors.green)), const SizedBox(width: 12), Expanded(child: _Metric(icon: Icons.track_changes,label: 'ACCURACY',value: '${p.accuracy}%',color: Colors.blue))]), const SizedBox(height: 22), Text('Category rhythm', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(children: PuzzleCategory.values.map((c) { final s = Map<String,dynamic>.from(p.categories[c.name] ?? {}); final a = s['attempted'] ?? 0; final solved = s['solved'] ?? 0; final ratio = a == 0 ? 0.0 : solved / a; return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [SizedBox(width: 82, child: Text(c.label)), Expanded(child: LinearProgressIndicator(value: ratio, borderRadius: BorderRadius.circular(8))), const SizedBox(width: 8), Text('$solved/$a')])); }).toList()))), const SizedBox(height: 22), Text('Achievement cabinet', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ..._achievementNames.map((a) => Card(child: ListTile(leading: Icon(p.achievements.contains(a) ? Icons.workspace_premium : Icons.lock_outline, color: p.achievements.contains(a) ? Theme.of(context).colorScheme.tertiary : null), title: Text(a), subtitle: Text(_achievementDetail(a)), trailing: p.achievements.contains(a) ? const Text('Earned') : const Text('Locked'))))]); }
}
const _achievementNames = ['First Spark', 'Daily Orbit', 'Three Day Current', 'Puzzle Cartographer', 'Precision Pulse', 'Point Voyager'];
String _achievementDetail(String a) => const {'First Spark':'Solve your first puzzle.', 'Daily Orbit':'Complete a full daily quest.', 'Three Day Current':'Complete three daily quests in a row.', 'Puzzle Cartographer':'Try each puzzle category.', 'Precision Pulse':'Reach 80% accuracy after ten attempts.', 'Point Voyager':'Earn 100 points.'}[a]!;

class SettingsTab extends StatelessWidget { const SettingsTab({super.key, required this.store, required this.changed}); final ProfileStore store; final VoidCallback changed;
 @override Widget build(BuildContext context) {
   final p = store.profile;
   Future<void> persist() async { await store.save(); changed(); }
   return ListView(padding: const EdgeInsets.all(20), children: [
     Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 16),
     Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
     Card(child: Column(children: [ListTile(title: const Text('Theme'), trailing: DropdownButton<String>(value: p.themeMode, items: const [DropdownMenuItem(value: 'system', child: Text('System')), DropdownMenuItem(value: 'light', child: Text('Light')), DropdownMenuItem(value: 'dark', child: Text('Dark'))], onChanged: (v) async { p.themeMode = v!; await persist(); })), SwitchListTile(title: const Text('Reduced motion'), subtitle: const Text('Minimise decorative movement.'), value: p.reducedMotion, onChanged: (v) async { p.reducedMotion = v; await persist(); })])),
     const SizedBox(height: 16), Text('Play preferences', style: Theme.of(context).textTheme.titleMedium),
     Card(child: Column(children: [SwitchListTile(title: const Text('Sound effects'), value: p.sound, onChanged: (v) async { p.sound = v; await persist(); }), SwitchListTile(title: const Text('Haptic feedback'), value: p.haptics, onChanged: (v) async { p.haptics = v; await persist(); }), ListTile(title: const Text('Starting difficulty'), trailing: DropdownButton<int>(value: p.difficulty, items: const [DropdownMenuItem(value: 1, child: Text('Gentle')), DropdownMenuItem(value: 2, child: Text('Balanced')), DropdownMenuItem(value: 3, child: Text('Bold'))], onChanged: (v) async { p.difficulty = v!; await persist(); }))])),
     const SizedBox(height: 16), Card(child: Column(children: [const ListTile(title: Text('Privacy'), subtitle: Text('MindQuest stores progress only on this device.')), ListTile(title: const Text('Reset local progress'), textColor: Theme.of(context).colorScheme.error, onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Reset all progress?'), content: const Text('This removes local scores, streaks, and achievements. This cannot be undone.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async { await store.reset(); if (context.mounted) { Navigator.pop(context); changed(); } }, child: const Text('Reset'))])))])),
   ]);
 }
}

class _Logo extends StatelessWidget { const _Logo(); @override Widget build(BuildContext context) => Container(width: 38,height: 38, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.psychology_alt, color: Colors.white)); }
class _Metric extends StatelessWidget { const _Metric({required this.icon,required this.label,required this.value,required this.color}); final IconData icon; final String label,value; final Color color; @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon,color: color),const SizedBox(height: 10),Text(value,style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),Text(label,style: Theme.of(context).textTheme.labelSmall)]))); }
class _CompletionCard extends StatelessWidget { const _CompletionCard({required this.store}); final ProfileStore store; @override Widget build(BuildContext context) => Card(color: Theme.of(context).colorScheme.tertiaryContainer, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const Icon(Icons.celebration, size: 42), const SizedBox(height: 8), Text('Daily quest complete!', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), Text('Your streak is now ${store.profile.streak} day${store.profile.streak == 1 ? '' : 's'}.')]))); }
