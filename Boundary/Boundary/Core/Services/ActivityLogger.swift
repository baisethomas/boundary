//
//  ActivityLogger.swift
//  Boundary
//

import Foundation

protocol ActivityLogging: AnyObject {
    func record(
        title: String,
        detail: String,
        kind: ActivityKind,
        ruleID: UUID?,
        at date: Date,
        in store: ActivityStore
    )
}

@MainActor
final class ActivityLogger: ActivityLogging {
    func record(
        title: String,
        detail: String,
        kind: ActivityKind,
        ruleID: UUID? = nil,
        at date: Date = .now,
        in store: ActivityStore
    ) {
        try? store.append(title: title, detail: detail, kind: kind, ruleID: ruleID, at: date)
    }
}
