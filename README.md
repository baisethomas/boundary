# Boundary

iOS app that **automatically activates quiet-time behavior** from calendar context and time-based rules (after hours, OOO, deep work). Local-first MVP: SwiftUI, MVVM, SwiftData—no backend.

## Open in Xcode

1. Clone this repo.
2. Open **`Boundary/Boundary.xcodeproj`**.
3. Select an iPhone simulator (or device) and run **⌘R**.

## Docs

- [PRD.md](PRD.md) — product and engineering requirements  
- [SwiftUI_Breakdown.md](SwiftUI_Breakdown.md) — UI architecture notes (see PRD §6 for layering)

## Repo layout

| Path | Purpose |
|------|---------|
| `Boundary/Boundary/` | App target sources (`App/`, `Core/`, `Features/`, `Shared/`) |
| `Boundary/BoundaryTests/` | Unit tests |
| `Boundary/BoundaryUITests/` | UI tests |

## Requirements

- Xcode with the iOS SDK version targeted by the project (see Xcode project settings).
- SwiftData store: if you hit migration issues after model changes, delete the app from the simulator and reinstall.

## License

All rights reserved unless you add a license file.
