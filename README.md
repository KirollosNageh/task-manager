# Task Manager — Flutter + Firebase

A mobile Task Manager app built with Flutter and Firebase as part of a technical interview task. Users can register, log in, and manage their own tasks with real-time sync, push notifications, and on-device due-time reminders.

## Project Overview

The app lets a user:
- Register, log in, log out, and reset a forgotten password (Firebase Authentication)
- Create, edit, delete, and mark tasks as Pending/Completed, with each task stored under that user's own space in Firestore (Cloud Firestore, real-time)
- Receive push notifications via Firebase Cloud Messaging (foreground, background, and terminated states, including tap-to-navigate)
- Receive a local on-device reminder exactly when a task's due date/time arrives
- Search and filter tasks, toggle dark mode, pull to refresh, and paginate through long task lists
- Keep working with cached data while offline, with changes syncing automatically once back online

State management is handled with **GetX** (controllers + reactive `.obs` state + named routing + dependency injection), chosen to keep state, navigation, and DI in one lightweight package for a project of this scope.

## Flutter Version

```
Flutter 3.41.9 (stable channel)
Dart SDK >= 3.11.5
```

Run `flutter --version` after cloning to confirm the exact version used to build this project, and `flutter doctor` to verify your environment is ready.

## How to Run the Project

### Prerequisites
- Flutter SDK installed ([flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install))
- A Firebase project (see [Firebase Setup](#firebase-setup-instructions) below)
- Android Studio or VS Code with the Flutter/Dart plugins
- An Android emulator or physical device (Android 6.0 / API 23 or higher)

### Steps
```bash
# 1. Clone the repository
git clone <YOUR_REPO_URL>
cd <REPO_FOLDER_NAME>

# 2. Install dependencies
flutter pub get

# 3. Connect your own Firebase project (see Firebase Setup below) —
#    this generates lib/firebase_options.dart and android/app/google-services.json
flutterfire configure

# 4. Run the app
flutter run
```

## Firebase Setup Instructions

This project uses Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging. To run it with your own Firebase backend:

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com) (Google Analytics can be disabled — not used in this project).

2. **Enable Authentication**
   Build → Authentication → Get started → Sign-in method → enable **Email/Password**.

3. **Enable Cloud Firestore**
   Build → Firestore Database → Create database → start in **production mode** → pick a location.

4. **Apply the Security Rules** (Firestore Database → Rules tab):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;

         match /tasks/{taskId} {
           allow read, write: if request.auth != null && request.auth.uid == userId;
         }
       }
     }
   }
   ```
   This scopes every read/write to the signed-in user's own `users/{uid}` document and their `tasks` subcollection — one user can never read or write another user's data.

5. **Cloud Messaging** is enabled automatically once an Android app is registered to the project — no separate manual step.

6. **Connect the Flutter project to your Firebase project**
   ```bash
   npm install -g firebase-tools      # if not already installed
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Select your Firebase project and the **android** platform. This generates `lib/firebase_options.dart` and `android/app/google-services.json` — both are required for the app to build and are intentionally not committed with real project credentials in a public template (see `.gitignore` notes below if you fork this).

### Firestore Data Structure
```
users (collection)
 └── {userId} (document)
      ├── email: string
      ├── fcmToken: string
      ├── createdAt: timestamp
      └── tasks (subcollection)
           └── {taskId} (document)
                ├── title: string
                ├── description: string
                ├── createdAt: timestamp
                ├── dueDate: timestamp
                └── status: "pending" | "completed"
```

## Packages Used

| Package | Purpose |
|---|---|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Email/password authentication |
| `cloud_firestore` | Real-time task storage |
| `firebase_messaging` | Push notifications (FCM) |
| `flutter_local_notifications` | On-device scheduled reminders for task due date/time |
| `timezone` / `flutter_timezone` | Accurate local-time scheduling for due-time reminders |
| `get` | State management, navigation, and dependency injection (GetX) |
| `intl` | Date/time formatting |

## Assumptions and Limitations

- **No backend/Cloud Functions.** All notification logic runs client-side. FCM push notifications require something to trigger them (tested manually via the Firebase Console or a direct API call); there is no server automatically watching for due tasks. On-device due-time reminders (`flutter_local_notifications`) cover the "notify me when a task is due" requirement without needing a backend.
- **Local reminders don't survive a device reboot.** Rescheduling all pending reminders after a reboot would require a boot-completed receiver and re-registration logic, which was out of scope for the project's time budget.
- **Pagination is simplified, by design.** Instead of cursor-based pagination, the task list grows its Firestore query `limit()` as the user requests more ("Load more" / scrolling near the bottom). This keeps every loaded task updating in real time, which matters more for a personal task list than deep pagination — most users will only ever have a handful of pages.
- **Search and filter apply to the currently loaded page(s) only**, not the user's entire task history, as a direct consequence of the pagination approach above.
- **Dark mode preference is not persisted** across app restarts (in-memory only) — no local storage package was added purely for this bonus feature.
- **Offline detection uses Firestore's own `metadata.isFromCache` signal**, not a dedicated connectivity package — this avoids an extra dependency while still surfacing an accurate "you're offline, showing cached data" banner.
- **The release APK is signed with the debug keystore** (`flutter build apk --release` using default debug signing), sufficient for review/testing but not intended for a Play Store submission.

## Architecture

Feature-first structure with a light data/presentation split per feature:
```
lib/
├── core/            # theme, routing, shared services (notifications), utils, constants
├── features/
│   ├── auth/        # data (repository) + presentation (controllers, screens, bindings)
│   └── tasks/        # data (model, repository) + presentation (controllers, screens, widgets, bindings)
└── shared/           # reusable widgets used across features (buttons, fields, state widgets)
```
Repositories are the only classes that talk to Firebase directly; controllers hold business logic and expose reactive state; screens only read state and render UI.
