# TaskPilot AI

A native iPhone productivity app that answers one question: *what is the next best
thing I should do right now?* Built with SwiftUI, SwiftData, and MVVM.

This project was scaffolded on Windows without Xcode. There is no `.xcodeproj`
checked in — generate it locally with [XcodeGen](https://github.com/yonaskolb/XcodeGen).

## Requirements

- macOS with Xcode 15.4+ (iOS 17 SDK)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`

## Setup

```bash
cd taskpilot-ai
xcodegen generate
open TaskPilotAI.xcodeproj
```

Select the `TaskPilotAI` scheme and run on an iOS 17+ simulator or device.

Re-run `xcodegen generate` any time `project.yml` changes or new source files are
added — XcodeGen picks up everything under `TaskPilotAI/` automatically, so you
generally don't need to touch Xcode's file list by hand.

## Current milestone: Core MVP

Implemented:

- Project architecture: MVVM + Repository pattern + protocol-based dependency
  injection (`AppDependencyContainer`)
- SwiftData persistence (`TaskItem` model, local only — no iCloud sync yet)
- Dashboard: next best task, today's tasks, overdue, completed today, progress
  ring, upcoming, pinned, quick add
- Smart Task Manager: create/edit/delete/complete/archive, priority, due
  date/time, category, notes, tags, estimated time, repeat rule
- Rule-based prioritization service (`TaskPrioritizationService`) computing
  next-best-task, urgent/important/quick-win/overdue classification

Not yet implemented (architecture leaves room for these, per the product spec):

- Natural language task input
- Siri / App Intents
- Notifications (local reminders, snooze, actions)
- Widgets (Home Screen + Lock Screen)
- Focus Mode
- iCloud sync
- AI-driven prioritization/suggestions (current prioritization is deterministic
  rule-based logic; `TaskPrioritizationServiceProtocol` is the seam a future
  AI-backed implementation would plug into)

## Project structure

```
TaskPilotAI/
  App/            App entry point, DI container
  Models/         SwiftData @Model types and enums
  Repositories/   Protocol + SwiftData-backed persistence
  Services/       Business logic (prioritization, etc.)
  ViewModels/     MVVM view models, one per screen
  Views/
    Dashboard/    Dashboard screen + its components
    TaskManager/  List/detail/form screens
    Components/   Shared, reusable SwiftUI views
  Utilities/      Formatting, small pure helpers
  Extensions/     Foundation/SwiftUI extensions
  AppIntents/     (reserved for Siri/Shortcuts work)
  Notifications/  (reserved for UserNotifications work)
  Widgets/        (reserved for WidgetKit extension)
TaskPilotAITests/     Unit tests
TaskPilotAIUITests/   UI tests
```

## Verifying changes

This codebase was authored without access to a Mac/Xcode toolchain, so it has
**not** been compiled locally. Two ways to verify it:

1. **CI (no Mac needed)** — `.github/workflows/ios-build.yml` runs on GitHub's
   free macOS runners on every push: it generates the Xcode project, builds,
   and runs the unit tests. Push this repo to GitHub and check the Actions
   tab for build/test results.
2. **Locally on a Mac** — after generating the Xcode project, build
   (`Cmd+B`) and run the unit tests (`Cmd+U`).

Either way, report back any compiler errors so they can be fixed.
