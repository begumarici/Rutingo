//
//  RoutinesViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 20.11.2025.
//

import Foundation

class RoutinesViewModel {
    private let dataManager: DataManager
    var allRoutines: [Routine] = []
    
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    func loadData() {
        let fetchedAllRoutines = dataManager.fetchAllRoutines()
        allRoutines = fetchedAllRoutines
    }
    
    func addRoutine(name: String, frequency: Frequency) {
        _ = dataManager.saveRoutine(name: name, frequency: frequency)
        loadData()
    }
    
    func deleteRoutine(_ routine: Routine) {
        dataManager.deleteRoutine(routine)
        loadData()
    }
}
