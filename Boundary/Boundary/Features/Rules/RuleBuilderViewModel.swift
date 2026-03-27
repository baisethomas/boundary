//
//  RuleBuilderViewModel.swift
//  Boundary
//
//  Draft state + validation for creating or editing a `PersistedRule` via `RulesStore`.
//

import Foundation
import SwiftUI

enum RuleBuilderError: LocalizedError {
    case missingTitle
    case invalidTrigger
    case invalidCustomQuietName

    var errorDescription: String? {
        switch self {
        case .missingTitle: return "Give your rule a name."
        case .invalidTrigger: return "Check trigger fields — keywords or weekdays may be missing."
        case .invalidCustomQuietName: return "Enter a label for your custom quiet mode."
        }
    }
}

@MainActor
@Observable
final class RuleBuilderViewModel {
    private(set) var editingRuleId: UUID?

    var step: RuleBuilderStep = .basics

    var ruleName: String = ""

    var triggerKind: RuleBuilderTriggerKind = .schedule

    var scheduleWeekdays: Set<Weekday> = Set(MockData.weekdaysWorkWeek)
    var scheduleStart: SimpleTime = SimpleTime(hour: 18)
    var scheduleEnd: SimpleTime = SimpleTime(hour: 8)

    var calendarKeywords: [String] = []
    var calendarKeywordDraft: String = ""
    var calendarMatchType: CalendarMatchType = .keywordPartial
    var calendarEventTypes: Set<CalendarEventType> = [.standard]

    var quietModeType: QuietModeType = .doNotDisturb
    var customQuietName: String = ""

    var restoreBehavior: RestoreBehavior = .revertPrevious

    var saveError: String?

    init(editing existing: BoundaryRule? = nil) {
        if let existing {
            editingRuleId = existing.id
            ruleName = existing.name
            restoreBehavior = existing.restoreBehavior
            quietModeType = existing.quietMode.modeType
            customQuietName = existing.quietMode.modeType == .custom ? existing.quietMode.displayName : ""

            switch existing.trigger {
            case let .schedule(s):
                triggerKind = .schedule
                scheduleWeekdays = Set(s.weekdays)
                scheduleStart = s.start
                scheduleEnd = s.end
            case let .calendar(c):
                triggerKind = .calendar
                calendarKeywords = c.keywords
                calendarMatchType = c.matchType
                calendarEventTypes = Set(c.allowedEventTypes)
            case let .hybrid(s, c):
                triggerKind = .hybrid
                scheduleWeekdays = Set(s.weekdays)
                scheduleStart = s.start
                scheduleEnd = s.end
                calendarKeywords = c.keywords
                calendarMatchType = c.matchType
                calendarEventTypes = Set(c.allowedEventTypes)
            }
        }
    }

    var isEditing: Bool { editingRuleId != nil }

    // MARK: - Review copy

    var reviewQuietLine: String {
        if quietModeType == .custom {
            let trimmed = customQuietName.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? QuietModeType.custom.displayName : trimmed
        }
        return quietModeType.displayName
    }

    var reviewTriggerDetail: String {
        switch triggerKind {
        case .schedule:
            let days = orderedSelectedWeekdays.map(\.shortSymbol).joined(separator: ", ")
            return "\(days)\n\(Self.formatTime(scheduleStart)) → \(Self.formatTime(scheduleEnd))"
        case .calendar:
            return calendarKeywords.isEmpty ? "—" : calendarKeywords.joined(separator: ", ")
        case .hybrid:
            let days = orderedSelectedWeekdays.map(\.shortSymbol).joined(separator: ", ")
            let sched = "\(days), \(Self.formatTime(scheduleStart)) → \(Self.formatTime(scheduleEnd))"
            let keys = calendarKeywords.isEmpty ? "—" : calendarKeywords.joined(separator: ", ")
            return "Schedule: \(sched)\nCalendar: \(keys)"
        }
    }

    private var orderedSelectedWeekdays: [Weekday] {
        Weekday.allCases.filter { scheduleWeekdays.contains($0) }
    }

    private static func formatTime(_ t: SimpleTime) -> String {
        var comp = DateComponents()
        comp.hour = t.hour
        comp.minute = t.minute
        guard let date = Calendar.current.date(from: comp) else {
            return String(format: "%d:%02d", t.hour, t.minute)
        }
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: date)
    }

    // MARK: - Validation

    var basicsValidationMessage: String? {
        ruleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Name is required."
            : nil
    }

    var triggerValidationMessage: String? {
        validateTriggerConfiguration() ? nil : triggerValidationFailureReason
    }

    private var triggerValidationFailureReason: String {
        switch triggerKind {
        case .schedule:
            return "Pick at least one day."
        case .calendar:
            return "Add at least one keyword."
        case .hybrid:
            return "Pick weekdays and at least one keyword."
        }
    }

    var quietValidationMessage: String? {
        if quietModeType == .custom,
           customQuietName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Enter a name for the custom mode."
        }
        return nil
    }

    func validateTriggerConfiguration() -> Bool {
        switch triggerKind {
        case .schedule:
            return !scheduleWeekdays.isEmpty
        case .calendar:
            return !calendarKeywords.isEmpty
        case .hybrid:
            return !scheduleWeekdays.isEmpty && !calendarKeywords.isEmpty
        }
    }

    func validateQuietConfiguration() -> Bool {
        quietValidationMessage == nil
    }

    var canProceedFromCurrentStep: Bool {
        switch step {
        case .basics:
            return basicsValidationMessage == nil
        case .trigger:
            return validateTriggerConfiguration()
        case .quiet:
            return validateQuietConfiguration()
        case .review:
            return canSave
        }
    }

    var canSave: Bool {
        basicsValidationMessage == nil
            && validateTriggerConfiguration()
            && validateQuietConfiguration()
            && buildTrigger() != nil
    }

    // MARK: - Navigation

    func goNext() {
        guard let next = RuleBuilderStep(rawValue: step.rawValue + 1) else { return }
        step = next
    }

    func goBack() {
        guard let prev = RuleBuilderStep(rawValue: step.rawValue - 1) else { return }
        step = prev
    }

    // MARK: - Build & save

    func buildQuietProfile() -> QuietModeProfile {
        if quietModeType == .custom {
            let name = customQuietName.trimmingCharacters(in: .whitespacesAndNewlines)
            return QuietModeProfile.baseline(for: .custom, name: name.isEmpty ? "Custom" : name)
        }
        return QuietModeProfile.baseline(for: quietModeType)
    }

    func buildTrigger() -> RuleTrigger? {
        switch triggerKind {
        case .schedule:
            let days = orderedSelectedWeekdays
            guard !days.isEmpty else { return nil }
            return .schedule(ScheduleTrigger(weekdays: days, start: scheduleStart, end: scheduleEnd))
        case .calendar:
            guard !calendarKeywords.isEmpty else { return nil }
            let types = calendarEventTypes.isEmpty ? [CalendarEventType.standard] : Array(calendarEventTypes)
            return .calendar(
                CalendarTrigger(
                    keywords: calendarKeywords,
                    matchType: calendarMatchType,
                    allowedEventTypes: types
                )
            )
        case .hybrid:
            let days = orderedSelectedWeekdays
            guard !days.isEmpty, !calendarKeywords.isEmpty else { return nil }
            let types = calendarEventTypes.isEmpty ? [CalendarEventType.standard] : Array(calendarEventTypes)
            let schedule = ScheduleTrigger(weekdays: days, start: scheduleStart, end: scheduleEnd)
            let calendar = CalendarTrigger(
                keywords: calendarKeywords,
                matchType: calendarMatchType,
                allowedEventTypes: types
            )
            return .hybrid(schedule: schedule, calendar: calendar)
        }
    }

    func save(using store: RulesStore) throws {
        saveError = nil
        let title = ruleName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw RuleBuilderError.missingTitle }
        guard validateQuietConfiguration() else { throw RuleBuilderError.invalidCustomQuietName }
        guard let trigger = buildTrigger() else { throw RuleBuilderError.invalidTrigger }

        let profile = buildQuietProfile()

        if let id = editingRuleId {
            try store.updateRule(
                id: id,
                title: title,
                trigger: trigger,
                quietProfile: profile,
                restoreBehavior: restoreBehavior
            )
        } else {
            try store.createRule(
                title: title,
                trigger: trigger,
                quietProfile: profile,
                restoreBehavior: restoreBehavior
            )
        }
    }
}
