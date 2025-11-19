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
    func saveRoutine(name: String, emoji: String, frequency: Frequency) -> Routine
    func deleteRoutine(_ routine: Routine)
    func toggleCompletion(_ routine: Routine)
    func save()
}
