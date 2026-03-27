# Boundary — SwiftUI Component Breakdown

## Architecture
- SwiftUI + MVVM; local-first SwiftData
- Canonical layering: **PRD Section 6** — UI, **State** (`AppState`, `RulesStore`, `ActivityStore`, `PermissionsManager`), **Services** (`CalendarService`, `RuleEngine`, `AutomationService`, `ActivityLogger`, `PersistenceService`, `EvaluationCoordinator`)

## Core Components

### App Shell
- BoundaryApp
- RootView
- MainTabView

### Screens
- Onboarding
- Home
- Rules
- Activity
- Settings

### Shared Components
- BoundaryCard
- SectionHeader
- StatusBadge
- PrimaryButton

### Home
- CurrentStateHeroCard
- NextBoundaryCard
- QuickActionBar

### Rules
- RuleRowCard
- RuleBuilderView
- ScheduleEditorCard
- CalendarTriggerEditorCard

### Activity
- ActivityRow
- ActivityTimelineList

### Services
- CalendarService
- RuleEngine
- AutomationService
- ActivityLogger
- PersistenceService (SwiftData)
- EvaluationCoordinator

### State (Core/State)
- AppState
- RulesStore
- ActivityStore
- PermissionsManager

## Build Priority
1. App shell
2. Models
3. Onboarding
4. Rule engine
5. UI polish
