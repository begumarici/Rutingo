//
//  TimeBlock-Extension.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 28.04.2026.
//

import Foundation

extension TimeBlock {
    var timeRangeText: String {
        let start = String(format: "%02d:00", startHour)
        let end   = String(format: "%02d:00", endHour)
        return "\(start) – \(end)"
    }

    var linkedRoutines: [Routine] {
        let set = routines as? Set<Routine> ?? []
        return Array(set).sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}
