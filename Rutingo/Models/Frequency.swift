//
//  Frequency.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 15.11.2025.
//

import Foundation

enum Frequency: Codable, Equatable {
    case daily
    case specificDays([Int])
    
    var displayText: String {
        switch self {
        case .daily:
            return "daily".localized
        case .specificDays(let days):
            let sortedDays = days.sorted { d1, d2 in
                let p1 = d1 == 1 ? 8 : d1
                let p2 = d2 == 1 ? 8 : d2
                return p1 < p2
            }
            
            let dayNames = sortedDays.compactMap { DayOfWeek(rawValue: $0)?.shortName }
            return dayNames.joined(separator: ", ")
        }
    }
}

enum DayOfWeek: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    
    var shortName: String {
        switch self {
        case .sunday: return "day_sun".localized
        case .monday: return "day_mon".localized
        case .tuesday: return "day_tue".localized
        case .wednesday: return "day_wed".localized
        case .thursday: return "day_thu".localized
        case .friday: return "day_fri".localized
        case .saturday: return "day_sat".localized
        }
    }
    
    var fullName: String {
        switch self {
        case .sunday: return "day_sunday".localized
        case .monday: return "day_monday".localized
        case .tuesday: return "day_tuesday".localized
        case .wednesday: return "day_wednesday".localized
        case .thursday: return "day_thursday".localized
        case .friday: return "day_friday".localized
        case .saturday: return "day_saturday".localized
        }
    }
}
    
/// A time-of-day range, used to override a routine's default start/end time for a specific weekday
/// (e.g. Monday 10:00–11:00 while the rest of the week stays at the routine's usual time).
struct DayTimeRange: Codable, Equatable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int

    var displayText: String {
        String(format: "%02d:%02d – %02d:%02d", startHour, startMinute, endHour, endMinute)
    }

    /// False if the end time isn't strictly after the start time (overnight ranges aren't supported).
    var isValid: Bool {
        (endHour * 60 + endMinute) > (startHour * 60 + startMinute)
    }
}
