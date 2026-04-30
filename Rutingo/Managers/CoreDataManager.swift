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
    func saveRoutine(
        name: String,
        frequency: Frequency,
        feeling: String? = nil,
        motivation: String? = nil,
        blockType: String? = nil,
        hasReminder: Bool = false,
        reminderTime: Date? = nil
    ) -> Routine {
        let routine = Routine(context: viewContext)
        routine.id = UUID()
        routine.name = name
        routine.frequency = frequency
        routine.feeling    = feeling
        routine.motivation = motivation
        routine.blockType  = blockType
        routine.createdAt = Date()
        
        routine.lastFrequencyChangeDate = DateHelper.shared.startOfDay(Date())
        
        routine.hasReminder = hasReminder
        routine.reminderTime = reminderTime
        save()
        return routine
    }
    
    func updateRoutine(routine: Routine, name: String, frequency: Frequency, feeling: String? = nil, motivation: String? = nil, blockType: String? = nil, hasReminder: Bool = false, reminderTime: Date? = nil) {
        
        if let oldData = routine.frequencyData {
            let oldFrequencyData = try? JSONEncoder().encode(frequency)
            
            if oldData != oldFrequencyData {
                routine.lastFrequencyChangeDate = DateHelper.shared.startOfDay(Date())
            }
        }
        
        routine.name = name
        routine.frequencyData = try? JSONEncoder().encode(frequency)
        routine.feeling    = feeling
        routine.motivation = motivation
        routine.blockType  = blockType
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
    
    // MARK: - TimeBlock
    func fetchBlocks(for date: Date) -> [TimeBlock] {
        let request: NSFetchRequest<TimeBlock> = TimeBlock.fetchRequest()
        let startOfDay = DateHelper.shared.startOfDay(date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as CVarArg,
            endOfDay   as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "startHour", ascending: true)]
        return (try? viewContext.fetch(request)) ?? []
    }

    func saveBlock(title: String, startHour: Int, endHour: Int, date: Date = Date()) -> TimeBlock {
        let block = TimeBlock(context: viewContext)
        block.id = UUID()
        block.title = title
        block.startHour = Int16(startHour)
        block.endHour = Int16(endHour)
        block.date = DateHelper.shared.startOfDay(date)
        block.createdAt = Date()
        save()
        return block
    }

    func deleteBlock(_ block: TimeBlock) {
        viewContext.delete(block)
        save()
    }

    func addRoutineToBlock(_ routine: Routine, block: TimeBlock) {
        block.addToRoutines(routine)
        save()
    }

    func removeRoutineFromBlock(_ routine: Routine, block: TimeBlock) {
        block.removeFromRoutines(routine)
        save()
    }

    // MARK: - Task
    func fetchAllTasks() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return (try? viewContext.fetch(request)) ?? []
    }

    func saveTask(title: String, category: String, priority: String, dueDate: Date? = nil) -> Task {
        let task         = Task(context: viewContext)
        task.id          = UUID()
        task.title       = title
        task.category    = category
        task.priority    = priority
        task.dueDate     = dueDate
        task.isCompleted = false
        task.createdAt   = Date()
        save()
        return task
    }

    func toggleTask(_ task: Task) {
        task.isCompleted = !task.isCompleted
        task.completedAt = task.isCompleted ? Date() : nil
        save()
    }

    func deleteTask(_ task: Task) {
        viewContext.delete(task)
        save()
    }

    // MARK: - Event
    func fetchEvents(for date: Date) -> [Event] {
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let startOfDay = DateHelper.shared.startOfDay(date)
        let endOfDay   = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            startOfDay as CVarArg,
            endOfDay   as CVarArg
        )
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        return (try? viewContext.fetch(request)) ?? []
    }

    func saveEvent(title: String, date: Date, time: Date? = nil) -> Event {
        let event       = Event(context: viewContext)
        event.id        = UUID()
        event.title     = title
        event.date      = DateHelper.shared.startOfDay(date)
        event.time      = time
        event.createdAt = Date()
        save()
        return event
    }

    func deleteEvent(_ event: Event) {
        viewContext.delete(event)
        save()
    }

    // MARK: - HabitSkipLog
    func saveSkipLog(routineId: UUID, date: Date, reason: String) {
        let log       = HabitSkipLog(context: viewContext)
        log.id        = UUID()
        log.routineId = routineId
        log.date      = DateHelper.shared.startOfDay(date)
        log.reason    = reason
        log.createdAt = Date()
        save()
    }

    func hasSkipLog(routineId: UUID, date: Date) -> Bool {
        let request: NSFetchRequest<HabitSkipLog> = HabitSkipLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "routineId == %@ AND date == %@",
            routineId as CVarArg,
            DateHelper.shared.startOfDay(date) as CVarArg
        )
        return ((try? viewContext.fetch(request))?.count ?? 0) > 0
    }

    // MARK: - WeeklyReview
    func saveWeeklyReview(weekStartDate: Date, rating: Int, note: String?) {
        let review           = WeeklyReview(context: viewContext)
        review.id            = UUID()
        review.weekStartDate = DateHelper.shared.startOfDay(weekStartDate)
        review.rating        = Int16(rating)
        review.note          = note
        review.createdAt     = Date()
        save()
    }

    func hasWeeklyReview(for weekStart: Date) -> Bool {
        let request: NSFetchRequest<WeeklyReview> = WeeklyReview.fetchRequest()
        request.predicate = NSPredicate(
            format: "weekStartDate == %@",
            DateHelper.shared.startOfDay(weekStart) as CVarArg
        )
        return ((try? viewContext.fetch(request))?.count ?? 0) > 0
    }

    func fetchAllReviews() -> [WeeklyReview] {
        let request: NSFetchRequest<WeeklyReview> = WeeklyReview.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "weekStartDate", ascending: false)]
        return (try? viewContext.fetch(request)) ?? []
    }
    
    
    
}
