//
//  CoreDataManager.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.11.2025.
//

import Foundation
import CoreData

class CoreDataManager: DataManager {
    
    // MARK: - Singleton
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Rutingo")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load Core Data: \(error)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Fetch Methods
    func fetchAllRoutines() -> [Routine] {
        let request: NSFetchRequest<Routine> = Routine.fetchRequest()
        
        do {
            let routines = try viewContext.fetch(request)
            let today = DateHelper.shared.startOfDay()
            return routines.filter { routine in
                guard let createdAt = routine.createdAt else { return false }
                let createdAtStart = DateHelper.shared.startOfDay(createdAt)
                return createdAtStart <= today
            }
        } catch {
            print("failed to fethc: \(error)")
            return []
        }
    }
    
    func fetchTodayRoutines() -> [Routine] {
        let allRoutines = fetchAllRoutines()
        return allRoutines.filter { $0.isScheduledToday }
    }
    
    // MARK: - CRUD Operations
    func saveRoutine(name: String, frequency: Frequency, hasReminder: Bool = false, reminderTime: Date? = nil) -> Routine {
        let routine = Routine(context: viewContext)
        routine.id = UUID()
        routine.name = name
        routine.frequency = frequency
        routine.createdAt = Date()
        
        routine.lastFrequencyChangeDate = DateHelper.shared.startOfDay(Date())
        
        routine.hasReminder = hasReminder
        routine.reminderTime = reminderTime
        save()
        return routine
    }
    
    func updateRoutine(routine: Routine, name: String, frequency: Frequency, hasReminder: Bool = false, reminderTime: Date? = nil) {
        
        if let oldData = routine.frequencyData {
            let oldFrequencyData = try? JSONEncoder().encode(frequency)
            
            if oldData != oldFrequencyData {
                routine.lastFrequencyChangeDate = DateHelper.shared.startOfDay(Date())
            }
        }
        
        routine.name = name
        routine.frequencyData = try? JSONEncoder().encode(frequency)
        routine.hasReminder = hasReminder
        routine.reminderTime = reminderTime
        save()
    }
    
    func deleteRoutine(_ routine: Routine) {
        viewContext.delete(routine)
        save()
    }
    
    func toggleCompletion(_ routine: Routine) {
        let today = DateHelper.shared.startOfDay()
        if let existing = routine.completionArray.first(where: {
            guard let date = $0.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }) {
            viewContext.delete(existing)
        } else {
            let completion = RoutineCompletion(context: viewContext)
            completion.id = UUID()
            completion.date = today
            completion.routine = routine
            completion.frequencySnapshot = routine.frequencyData
        }
        save()
    }
    
    func save() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
    
    func clearAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Routine.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("Error clearing all data: \(error)")
        }
    }
}
