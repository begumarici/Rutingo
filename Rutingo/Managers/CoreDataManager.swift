//
//  CoreDataManager.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.11.2025.
//

import Foundation
import CoreData

class CoreDataManager: DataManager {
    static let shared = CoreDataManager()
    private init() {}
    
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
    
    func fetchAllRoutines() -> [Routine] {
        let request: NSFetchRequest<Routine> = Routine.fetchRequest()
        
        do {
            let routines = try viewContext.fetch(request)
            return routines
        } catch {
            print("failed to fethc: \(error)")
            return []
        }
    }
    
    func fetchTodayRoutines() -> [Routine] {
        let allRoutines = fetchAllRoutines()
        return allRoutines.filter { $0.isScheduledToday }
    }
    
    func saveRoutine(name: String, frequency: Frequency, hasReminder: Bool = false, reminderTime: Date? = nil) -> Routine {
        let routine = Routine(context: viewContext)
        routine.id = UUID()
        routine.name = name
        routine.frequency = frequency
        routine.createdAt = Date()
        routine.hasReminder = hasReminder
        routine.reminderTime = reminderTime
        save()
        return routine
    }
    
    func updateRoutine(routine: Routine, name: String, frequency: Frequency, hasReminder: Bool = false, reminderTime: Date? = nil) {
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
        }
        save()
    }
    
    func save() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
}
