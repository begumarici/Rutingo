//
//  TimeBlock-Extension.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 28.04.2026.
//

import Foundation

extension TimeBlock {
    var timeRangeText: String {
        let start = String(format: "%02d:%02d", startHour, startMinute)
        let end   = String(format: "%02d:%02d", endHour, endMinute)
        return "\(start) – \(end)"
    }

    var linkedRoutines: [Routine] {
        let set = routines as? Set<Routine> ?? []
        return Array(set).sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    /// Whether this block's linked routine was completed on the block's own day.
    /// Only the first linked routine is considered, matching how the rest of the app treats block↔routine links.
    var isRoutineCompleted: Bool {
        guard let routine = linkedRoutines.first, let date = date else { return false }
        return routine.isCompleted(on: date)
    }

    var isRoutineSkipped: Bool {
        guard let routine = linkedRoutines.first, let date = date else { return false }
        return routine.isSkipped(on: date)
    }

    enum RoutineBlockStatus: Equatable {
        case none       // not linked to a routine
        case pending    // linked, but the day/time hasn't happened yet
        case completed
        case skipped
        case missed
    }

    /// The block's completion status, shared by the timeline view and the block detail screen
    /// so "missed" is computed the same way (own day/end time already passed) everywhere.
    var routineStatus: RoutineBlockStatus {
        guard !linkedRoutines.isEmpty else { return .none }
        if isRoutineCompleted { return .completed }
        if isRoutineSkipped { return .skipped }

        guard let date = date else { return .pending }
        let today = DateHelper.shared.startOfDay()
        let blockDay = DateHelper.shared.startOfDay(date)

        if blockDay < today { return .missed }
        if blockDay == today {
            let now = Date()
            let nowDecimal = Double(Calendar.current.component(.hour, from: now))
                + Double(Calendar.current.component(.minute, from: now)) / 60.0
            let endDecimal = Double(endHour) + Double(endMinute) / 60.0
            if endDecimal <= nowDecimal { return .missed }
        }
        return .pending
    }
}
