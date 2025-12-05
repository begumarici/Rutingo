//
//  DataManager.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.11.2025.
//

import Foundation

protocol DataManager {
    func fetchAllRoutines() -> [Routine]
    func fetchTodayRoutines() -> [Routine]
    func saveRoutine(name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date?) -> Routine
    func deleteRoutine(_ routine: Routine)
    func updateRoutine(routine: Routine, name: String, frequency: Frequency, hasReminder: Bool, reminderTime: Date?) 
    func toggleCompletion(_ routine: Routine)
    func save()
}
