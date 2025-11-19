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
    
    func saveRoutine(name: String, emoji: String, frequency: Frequency) -> Routine {
        let routine = Routine(context: viewContext)
        routine.id = UUID()
        routine.name = name
        routine.emoji = emoji
        routine.frequency = frequency
        routine.createdAt = Date()
        save()
        return routine
    }
    
    func deleteRoutine(_ routine: Routine) {
        viewContext.delete(routine)
        save()
    }
    
    func toggleCompletion(_ routine: Routine) {
        routine.toggleCompletion()
        save()
    }
    
    func save() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
}
