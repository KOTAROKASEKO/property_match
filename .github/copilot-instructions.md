<!-- Copilot instructions for contributors and AI agents -->
# Quick orientation for AI coding agents

Purpose: give focused, actionable context so an AI assistant can be productive immediately in this Flutter monorepo.

- **Big picture**: This is a Flutter monorepo (app + packages + Cloud Functions). Mobile and web share most UI code under `lib/3-shared`, with platform-specific persistence packages: `packages/chatrepo_isar` (mobile) and `packages/chatrepo_drift` (web). Firebase (Auth, Firestore, Messaging, Functions) is central to app behavior.

- **Key directories & files**:
  - `lib/main.dart` — app bootstrap, providers, Firebase init, routing and deep-link handling.
  - `lib/3-shared/` — shared features organized with numeric prefixes (e.g. `1_agent_feature`, `2_tenant_feature`). Follow this numbering when adding features.
  - `lib/3-shared/agent_main_scaffold.dart` — example of navigation, pending-action handling, and chat navigation patterns.
  - `packages/*` — local packages used across platforms (see `pubspec.yaml` for paths).
  - `functions/` — Node Cloud Functions entrypoint at `functions/index.js` and server-side AI helpers under `functions/src/ai_chat`.
  - `pubspec.yaml` and `melos.yaml` — dependency & monorepo config.

- **Important architecture notes**:
  - Role-based UX: users are assigned `agent` or `tenant` roles (persisted in SharedPreferences + Firestore). Role selection shapes initial navigation in `AuthWrapper` (see `lib/main.dart`).
  - State management: `Provider` + `ChangeNotifier` is used app-wide (see `MultiProvider` in `main.dart`). When adding stateful features, expose `ChangeNotifier` and register it in `main.dart` or the appropriate feature entry.
  - Global singletons: `userData` (from `shared_data`) is used widely. Use it rather than re-querying Firebase auth in many places.
  - Notifications: Firebase Messaging background/foreground handlers are declared in `main.dart` — be careful when changing message types or navigation from notifications.

- **Persistence differences**:
  - Web chat uses `drift` implementation (`packages/chatrepo_drift`). Mobile chat uses `isar` (`packages/chatrepo_isar`). Check package selection when touching the chat stack or local DB code.

- **Codegen / build steps** (use these exact commands):
  - Install monorepo dependencies: `melos bootstrap` (or run `flutter pub get` in specific packages).
  - Generate code: `flutter pub run build_runner build --delete-conflicting-outputs`.
  - Run web app: `flutter run -d chrome` (or `flutter build web`).
  - Run mobile: `flutter run -d <deviceId>` or use `flutter build apk/ios`.
  - Tests: `flutter test` at repo root or inside package folders.
  - Cloud Functions: `cd functions && npm install` then use Firebase CLI (`firebase deploy --only functions`) or emulators (`firebase emulators:start --only functions`) when available.

- **Env & secrets**:
  - The app uses a `.env` loaded by `flutter_dotenv` (see `main.dart` and `pubspec.yaml`). Ensure `.env` exists locally; do not commit secrets.
  - Firebase config is provided via `lib/3-shared/firebase_options.dart` — do not hand-edit unless intentionally changing platforms.

- **Project conventions & patterns to follow**:
  - Numeric folder prefixes for features (e.g. `1_agent_feature`) — keep this pattern when adding new features.
  - Use `Provider`/`ChangeNotifier` and register in `main.dart` for cross-app availability.
  - For navigation triggered from notifications or pending actions, prefer the existing `pendingAction` pattern and `PendingActionType` used by `agent_main_scaffold.dart`.
  - When adding server-side logic that interacts with clients, mirror message/data keys used by existing functions (see `functions/index.js` exports and `functions/src/*`).

- **Examples** (copy/paste snippets to follow patterns):
  - Register a ChangeNotifier:

    final ChangeNotifierProvider(create: (_) => MyFeatureViewModel()),

  - Navigate to a chat thread (follow UID sorting used elsewhere):

    List<String> uids = [userData.userId, other.uid];
    uids.sort();
    final chatThreadId = uids.join('_');

- **Where to look when debugging common issues**:
  - Firebase auth/role resolution: `lib/main.dart` (`AuthWrapper`, `_getRoleFromPrefs`).
  - Notification routing and background handlers: `lib/main.dart` and `agent_main_scaffold.dart`.
  - Cloud Functions behavior and AI agents: `functions/src/ai_chat` and `functions/index.js`.

If anything above is unclear or you'd like the instructions expanded (examples for running emulators, or a short onboarding checklist), tell me which area to expand and I will iterate.
