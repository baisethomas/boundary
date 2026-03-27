//
//  BoundaryState.swift
//  Boundary
//

import Foundation

/// PRD Section 10 — runtime boundary state machine (persist pause via `AppConfiguration`).
enum BoundaryState: Equatable, Sendable {
    case inactive
    case active(ruleId: UUID)
    case paused
}
