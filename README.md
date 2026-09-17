# MindQuest

MindQuest is an original offline-first Flutter brain puzzle game. It offers a deterministic five-puzzle daily quest, unlimited practice, local scoring, streaks, achievements, statistics, light/dark themes, and reduced-motion support.

## Puzzle trails

- Pattern and sequence
- Logic deduction
- Visual memory
- Word and letter play
- Mental maths
- Spatial reasoning

Puzzle progress (streaks, points, achievements) stays on-device using `shared_preferences` and needs no network connection to play. The app also integrates anonymous Firebase authentication (for a future leaderboard) and an AdMob banner ad; both require network access and are configured for the `mindquest-686e9` Firebase project.

## Run locally

Install Flutter, then run:

```sh
flutter pub get
flutter run
```

## Android build

The included GitHub Actions workflow runs tests and publishes `mindquest-release-apk` as a workflow artifact. It runs `flutter create --platforms=android` first so a standard Flutter Android wrapper and launcher assets are generated in CI.

## Architecture

- `lib/services/puzzle_engine.dart`: date-seeded, validated puzzle generation and scoring
- `lib/services/profile_store.dart`: local profile, daily completion, streak, and achievement persistence
- `lib/models/`: app data models
- `lib/main.dart`: Material 3 UI and game flow
