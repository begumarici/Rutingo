//
//  RoutineFormData.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 09.07.2026.
//

import Foundation

/// Bundles everything the add/edit routine form collects, so the save/update call sites
/// don't have to pass a growing list of positional parameters in the right order.
struct RoutineFormData {
    let name: String
    let frequency: Frequency
    let feeling: String?
    let motivation: String?
    let blockType: String?
    let hasReminder: Bool
    let reminderTime: Date?
    let startHour: Int16
    let startMinute: Int16
    let endHour: Int16
    let endMinute: Int16
    let isCountBased: Bool
    let targetValue: Double
    let unit: RoutineUnit
}
