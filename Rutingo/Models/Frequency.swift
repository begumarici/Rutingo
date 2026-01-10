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
            return "daily".localized
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
