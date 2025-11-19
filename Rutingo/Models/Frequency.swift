//
//  Frequency.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 15.11.2025.
//

enum Frequency: Codable {
    case daily
    case specificDays([Int])
    
    var displayText: String {
        switch self {
        case .daily:
            return "Daily"
        case .specificDays(let days):
            let dayNames = days.compactMap { DayOfWeek(rawValue: $0)?.shortName }
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
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}
