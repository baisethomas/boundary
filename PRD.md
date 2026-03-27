# Boundary — Product Requirements Document (Engineering-Ready)

---

# 1. Product Overview

## Product Name

Boundary

## One-Line Summary

Boundary is an iOS productivity app that automatically activates quiet-time behavior based on calendar events and time-based rules.

## Core Value Proposition

Boundary enforces user-defined boundaries automatically by connecting calendar context and schedules to iOS Focus behavior.

---

# 2. Problem Statement

Users have access to Focus modes, notifications, and calendars, but:

* Controls are fragmented
* Activation is manual
* Behavior is inconsistent

Result:

* After-hours interruptions
* OOO time not respected
* Focus blocks ineffective

---

# 3. Product Goals

## Primary Goal

Automate quiet-time behavior using calendar + time-based triggers.

## Success Criteria

* Onboarding < 3 minutes
* First rule created
* First automation triggered within 24 hours
* User understands WHY a rule triggered

---

# 4. Target Users

## Primary

* Professionals (corporate, remote, hybrid)
* Founders / consultants

## Secondary

* Parents
* Work-life balance seekers

---

# 5. Core Use Cases

### After Hours

Trigger quiet mode based on schedule (e.g., 6PM–8AM weekdays)

### Out of Office

Trigger quiet mode when calendar event matches OOO

### Deep Work

Trigger quiet mode during focus blocks

---

# 6. System Architecture (MVP)

## Layers

### UI Layer

* SwiftUI Views
* ViewModels (MVVM)

### State Layer

* AppState
* RulesStore
* ActivityStore
* PermissionsManager

### Service Layer

* CalendarService (EventKit)
* RuleEngine
* AutomationService (Focus orchestration)
* ActivityLogger
* PersistenceService

---

# 7. Data Models (Summary)

## BoundaryRule

* id
* name
* isEnabled
* trigger
* quietMode
* restoreBehavior

## RuleTrigger

* schedule
* calendar
* hybrid

## ActivityItem

* timestamp
* type (activated, ended, skipped, override)
* rule reference

## AppState

* onboardingComplete
* isPaused
* currentBoundaryState

---

# 8. Rule Engine Specification

## Inputs

* current datetime
* active rules
* calendar events

## Evaluation Order

1. Check global pause
2. Filter enabled rules
3. Evaluate schedule rules
4. Evaluate calendar rules
5. Resolve conflicts (priority: calendar > schedule)

## Output

* active rule (optional)
* boundary state (active/inactive)
* reason
* next trigger time

---

# 9. Trigger Definitions

## Schedule Trigger

* daysOfWeek
* startTime
* endTime

## Calendar Trigger

* keywords ("OOO", "Vacation", "Focus")
* event time overlap

## Matching Logic

* case-insensitive keyword match
* partial string match allowed

---

# 10. Boundary State Machine

## States

* Inactive
* Active(ruleId)
* Paused

## Transitions

* Inactive → Active (rule match)
* Active → Inactive (rule ends)
* Any → Paused (manual override)
* Paused → Inactive (resume)

---

# 11. Automation Behavior

## When Rule Activates

* Update AppState
* Log activity
* Trigger Focus behavior (or guide user)

## When Rule Ends

* Apply restore behavior
* Log activity

## Restore Options

* revert to previous state
* default state
* maintain current

---

# 12. Permissions

## Required

* Calendar (EventKit)

## States

* notDetermined
* authorized
* denied

## Handling

* Block rule creation if not authorized
* Show fallback UI

---

# 13. Persistence Strategy

## Storage

* SwiftData (preferred) OR Codable + file storage

## Persisted Items

* rules
* settings
* activity
* onboarding state

---

# 14. Background Behavior

## Evaluation Triggers

* app launch
* foreground entry
* periodic refresh (lightweight)

## Constraints

* no guaranteed background execution
* rely on foreground + scheduled checks

---

# 15. Error Handling

## Cases

* calendar permission denied
* no matching events
* invalid rule config

## Behavior

* fail silently + log
* surface status in UI

---

# 16. UI Requirements

## Home

* current state
* next trigger
* quick actions

## Rules

* list
* toggle
* create/edit

## Activity

* timeline grouped by date

## Settings

* permissions
* preferences

---

# 17. Metrics

## Product

* onboarding completion
* rules created
* successful triggers

## Engagement

* WAU
* rule usage frequency

## Monetization

* conversion rate
* MRR

---

# 18. Monetization

## Free

* 1 rule

## Pro

* unlimited rules
* advanced triggers
* activity history

---

# 19. Risks & Mitigation

## iOS Limitations

* Mitigation: use Focus + guidance

## Complexity

* Mitigation: presets + simple onboarding

## Trust

* Mitigation: activity log + transparency

---

# 20. Definition of Done

* onboarding complete
* rule created
* rule triggers successfully
* activity logged
* UI reflects state clearly

---

# 21. Engineering Notes

## Priorities

1. Rule Engine
2. EventKit integration
3. State management
4. Onboarding
5. UI polish

## Principles

* keep logic simple
* deterministic behavior
* minimal dependencies

---

# 22. Summary

Boundary connects calendar context to automatic quiet-time enforcement.

The MVP proves:
Users will trust automation to protect their time.

