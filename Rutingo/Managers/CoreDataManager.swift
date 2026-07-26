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

    /// Clamps a routine's target to a safe minimum, rejecting NaN/infinite input (which `max` would otherwise propagate).
    private static func sanitizedTarget(_ value: Double) -> Double {
        guard value.isFinite else { return 1 }
        return max(value, 0.01)
    }

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
        reminderTime: Date? = nil,
        startHour: Int16,
        startMinute: Int16,
        endHour: Int16,
        endMinute: Int16,
        isCountBased: Bool = false,
        targetValue: Double = 1,
        unit: RoutineUnit = .count,
        dayTimeRanges: [Int: DayTimeRange] = [:]
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
        routine.startHour = startHour
        routine.startMinute = startMinute
        routine.endHour = endHour
        routine.endMinute = endMinute
        routine.isCountBased = isCountBased
        routine.targetValue = Self.sanitizedTarget(targetValue)
        routine.routineUnit = unit
        routine.dayTimeRanges = dayTimeRanges
        save()
        return routine
    }
    
    func updateRoutine(
        routine: Routine,
        name: String,
        frequency: Frequency,
        feeling: String? = nil,
        motivation: String? = nil,
        blockType: String? = nil,
        hasReminder: Bool = false,
        reminderTime: Date? = nil,
        startHour: Int16,
        startMinute: Int16,
        endHour: Int16,
        endMinute: Int16,
        isCountBased: Bool = false,
        targetValue: Double = 1,
        unit: RoutineUnit = .count,
        dayTimeRanges: [Int: DayTimeRange] = [:]
    ) {
        
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
        routine.startHour = startHour
        routine.startMinute = startMinute
        routine.endHour = endHour
        routine.endMinute = endMinute
        routine.isCountBased = isCountBased
        routine.targetValue = Self.sanitizedTarget(targetValue)
        routine.routineUnit = unit
        routine.dayTimeRanges = dayTimeRanges
        save()
    }
    
    func deleteRoutine(_ routine: Routine) {
        viewContext.delete(routine)
        save()
    }
    
    func toggleCompletion(_ routine: Routine, on date: Date) {
        let day = DateHelper.shared.startOfDay(date)
        guard let routineId = routine.id else { return }

        if let existing = existingCompletion(for: routine, on: day) {
            viewContext.delete(existing)
        } else {
            // delete related skip log if there is a skip log for that day
            deleteSkipLog(routineId: routineId, date: day)

            let completion = makeCompletion(for: routine, date: day)
            completion.currentValue = routine.isCountBased ? 1 : 0
        }
        save()
    }

    /// Standard step size for +/- controls: whole units for everything (1 count, 1 km, 1 min, ...) — finer values go through `setCompletionValue`.
    private static let goalStep: Double = 1

    private func existingCompletion(for routine: Routine, on date: Date) -> RoutineCompletion? {
        routine.completionArray.first {
            guard let d = $0.date else { return false }
            return Calendar.current.isDate(d, inSameDayAs: date)
        }
    }

    /// Creates a new completion record, snapshotting the routine's current frequency and goal-tracking mode/target
    /// so later edits to the routine don't retroactively change how this day is judged.
    private func makeCompletion(for routine: Routine, date: Date) -> RoutineCompletion {
        let completion = RoutineCompletion(context: viewContext)
        completion.id = UUID()
        completion.date = date
        completion.routine = routine
        completion.frequencySnapshot = routine.frequencyData
        completion.wasCountBased = routine.isCountBased
        completion.targetSnapshot = routine.targetValue
        return completion
    }

    /// Finds or creates a completion record for the given day and sets its value, clamped to [0, target].
    /// A clamped value of 0 deletes the record instead — there's nothing to track for that day.
    private func setCompletionValue(_ routine: Routine, to newValue: Double, on date: Date) {
        let day = DateHelper.shared.startOfDay(date)
        let target = max(routine.targetValue, 0.01)
        let clampedValue = min(max(newValue, 0), target)
        let existing = existingCompletion(for: routine, on: day)

        guard clampedValue > 0 else {
            if let existing { viewContext.delete(existing) }
            save()
            return
        }

        if let existing {
            existing.currentValue = clampedValue
        } else if let routineId = routine.id {
            deleteSkipLog(routineId: routineId, date: day)
            makeCompletion(for: routine, date: day).currentValue = clampedValue
        }
        save()
    }

    /// Increments a day's progress value for a goal-based routine (e.g. 4 glasses of water), capped at the target.
    func incrementCompletionCount(_ routine: Routine, on date: Date) {
        let current = existingCompletion(for: routine, on: DateHelper.shared.startOfDay(date))?.currentValue ?? 0
        setCompletionValue(routine, to: current + Self.goalStep, on: date)
    }

    /// Jumps a day's progress straight to the target for a goal-based routine (e.g. "complete" from the context menu).
    func completeCompletionCount(_ routine: Routine, on date: Date) {
        setCompletionValue(routine, to: routine.targetValue, on: date)
    }

    /// Decrements a day's progress value for a goal-based routine, deleting the completion record once it reaches 0.
    func decrementCompletionCount(_ routine: Routine, on date: Date) {
        let current = existingCompletion(for: routine, on: DateHelper.shared.startOfDay(date))?.currentValue ?? 0
        guard current > 0 else { return }
        setCompletionValue(routine, to: current - Self.goalStep, on: date)
    }

    /// Sets a day's progress to an exact value typed in by the user (e.g. "5.5" km).
    func setCompletionValue(_ routine: Routine, value: Double, on date: Date) {
        guard value.isFinite else { return }
        setCompletionValue(routine, to: value, on: date)
    }

    /// Resets a day's progress back to 0 for a goal-based routine.
    func resetCompletionCount(_ routine: Routine, on date: Date) {
        setCompletionValue(routine, to: 0, on: date)
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
        request.sortDescriptors = [NSSortDescriptor(key: "startHour", ascending: true),
                                   NSSortDescriptor(key: "startMinute", ascending: true)
        ]
       
        return (try? viewContext.fetch(request)) ?? []
    }

    func saveBlock(title: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, date: Date = Date()) -> TimeBlock {
        let block = TimeBlock(context: viewContext)
        block.id = UUID()
        block.title = title
        block.startHour = Int16(startHour)
        block.startMinute = Int16(startMinute)
        block.endHour = Int16(endHour)
        block.endMinute = Int16(endMinute)
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
    
    func deleteGeneratedBlocks(for routine: Routine) {
        guard let routineID = routine.id else { return }
        
        let request: NSFetchRequest<TimeBlock> = TimeBlock.fetchRequest()
        request.predicate = NSPredicate(
            format: "isGeneratedFromRoutine == YES AND sourceRoutineID == %@",
            routineID as CVarArg
        )
        do {
            let blocks = try viewContext.fetch(request)
            blocks.forEach { viewContext.delete($0) }
            save()
        } catch {
            print("failed to delete generated blocks: ", error)
        }
    }
    
    func deleteGeneratedBlocksFromNow(for routine: Routine) {
        guard let routineID = routine.id else { return }
        
        let now = Date()
        let todayStart = Calendar.current.startOfDay(for: now)
        let currentHour = Calendar.current.component(.hour, from: now)
        let currentMinute = Calendar.current.component(.minute, from: now)
        
        let request: NSFetchRequest<TimeBlock> = TimeBlock.fetchRequest()
        request.predicate = NSPredicate(
            format: "isGeneratedFromRoutine == YES AND sourceRoutineID == %@ AND date >= %@",
            routineID as CVarArg,
            todayStart as CVarArg
        )
        
        do {
            let blocks = try viewContext.fetch(request)
            for block in blocks {
                guard let blockDate = block.date else { continue }
                let isToday = Calendar.current.isDate(blockDate, inSameDayAs: now)
                
                if isToday {
                    // Aynı gün — block'un bitiş saati şu andan önceyse silme
                    let blockEndHour = Int(block.endHour)
                    let blockEndMinute = Int(block.endMinute)
                    let blockAlreadyPassed = (blockEndHour < currentHour) ||
                                             (blockEndHour == currentHour && blockEndMinute <= currentMinute)
                    if blockAlreadyPassed { continue }
                }
                
                viewContext.delete(block)
            }
            save()
        } catch {
            print("failed to delete future generated blocks: \(error)")
        }
    }
    
    /// Deletes a routine's generated blocks from today onward (inclusive), leaving past blocks
    /// untouched. Used by syncGeneratedBlocks, which is about to regenerate today's block anyway —
    /// unlike deleteGeneratedBlocksFromNow, there's no "already passed today" exception here.
    private func deleteGeneratedBlocksFromToday(for routine: Routine) {
        guard let routineID = routine.id else { return }

        let todayStart = Calendar.current.startOfDay(for: Date())
        let request: NSFetchRequest<TimeBlock> = TimeBlock.fetchRequest()
        request.predicate = NSPredicate(
            format: "isGeneratedFromRoutine == YES AND sourceRoutineID == %@ AND date >= %@",
            routineID as CVarArg,
            todayStart as CVarArg
        )

        do {
            let blocks = try viewContext.fetch(request)
            blocks.forEach { viewContext.delete($0) }
            save()
        } catch {
            print("failed to delete today-onward generated blocks: \(error)")
        }
    }

    /// Regenerates a single day's generated block for a routine — e.g. after unskipping a specific
    /// date. Unlike syncGeneratedBlocks (which only rolls forward from today), this works for any
    /// date including past ones, and only touches that one day.
    func regenerateBlock(for routine: Routine, on date: Date) {
        guard let routineID = routine.id, let routineName = routine.name else { return }
        let day = Calendar.current.startOfDay(for: date)

        let alreadyExists = fetchBlocks(for: day).contains {
            $0.isGeneratedFromRoutine && $0.sourceRoutineID == routineID
        }
        guard !alreadyExists,
              isRoutine(routine, scheduledOn: day),
              !hasSkipLog(routineId: routineID, date: day)
        else { return }

        let hasTime = (routine.startHour >= 0 && routine.endHour >= 0) || !routine.dayTimeRanges.isEmpty
        guard hasTime else { return }

        let range = routine.timeRange(for: day)
        // Defensive: a day with neither its own override nor a valid default range (e.g. startHour
        // -1 from a routine with dayTimeRanges but no default time) shouldn't produce a corrupt block.
        guard range.isValid else { return }
        let block = TimeBlock(context: viewContext)
        block.id = UUID()
        block.title = routineName
        block.date = day
        block.createdAt = Date()
        block.startHour = Int16(range.startHour)
        block.startMinute = Int16(range.startMinute)
        block.endHour = Int16(range.endHour)
        block.endMinute = Int16(range.endMinute)
        block.isGeneratedFromRoutine = true
        block.sourceRoutineID = routineID
        block.addToRoutines(routine)

        save()
    }

    func syncGeneratedBlocks(for routine: Routine) {
        // A routine has a schedulable time either via its single default range, or via per-weekday
        // overrides (which can be set even when the default range itself is off).
        let hasTime = (routine.startHour >= 0 && routine.endHour >= 0) || !routine.dayTimeRanges.isEmpty
        guard
            let routineID = routine.id,
            let routineName = routine.name,
            hasTime
        else {
            deleteGeneratedBlocksFromToday(for: routine)
            return
        }

        // Only today-onward blocks get wiped and regenerated — past blocks stay untouched so
        // editing a routine (even just renaming it) doesn't erase its history. (Unlike
        // deleteGeneratedBlocksFromNow, today's block is always cleared here — it's about to be
        // recreated below, so keeping it would leave a duplicate for today.)
        deleteGeneratedBlocksFromToday(for: routine)
        let dates = scheduledDates(for: routine, daysAhead: 30)
        
        for date in dates {
            let range = routine.timeRange(for: date)
            // Defensive: skip a day that has neither its own override nor a valid default range.
            guard range.isValid else { continue }
            let block = TimeBlock(context: viewContext)
            block.id = UUID()
            block.title = routineName
            block.date = Calendar.current.startOfDay(for: date)
            block.createdAt = Date()
            block.startHour = Int16(range.startHour)
            block.startMinute = Int16(range.startMinute)
            block.endHour = Int16(range.endHour)
            block.endMinute = Int16(range.endMinute)
            block.isGeneratedFromRoutine = true
            block.sourceRoutineID = routineID
            
            block.addToRoutines(routine)
        }
        
        save()
    }
    
    // helper
    private func scheduledDates(for routine: Routine, daysAhead: Int) -> [Date] {
        let today = Calendar.current.startOfDay(for: Date())
        let routineId = routine.id
        var dates: [Date] = []
        for offset in 0..<daysAhead {
            guard let date = Calendar.current.date(
                byAdding: .day,
                value: offset,
                to: today
            ) else {
                continue
            }
            // Skipped days should never get a block regenerated, even if the routine is later
            // edited — otherwise a skipped occurrence can silently reappear on the timeline.
            if let routineId, hasSkipLog(routineId: routineId, date: date) {
                continue
            }
            if isRoutine(routine, scheduledOn: date) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func isRoutine(_ routine: Routine, scheduledOn date: Date) -> Bool {
        let frequency = routine.frequency
        let weekday = Calendar.current.component(.weekday, from: date)

        switch frequency {
        case .daily:
            return true

        case .specificDays(let days):
            return days.contains(weekday)
        }
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
        let todayStart = DateHelper.shared.startOfDay(date)

        // delete related copmletion if there is a completion in that day
        let fetchRequest: NSFetchRequest<RoutineCompletion> = RoutineCompletion.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "routine.id == %@ AND date == %@",
            routineId as CVarArg,
            todayStart as CVarArg
        )

        if let completions = try? viewContext.fetch(fetchRequest) {
            completions.forEach { viewContext.delete($0) }
        }

        let log       = HabitSkipLog(context: viewContext)
        log.id        = UUID()
        log.routineId = routineId
        log.date      = todayStart
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

    func deleteSkipLog(routineId: UUID, date: Date) {
        let request: NSFetchRequest<HabitSkipLog> = HabitSkipLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "routineId == %@ AND date == %@",
            routineId as CVarArg,
            DateHelper.shared.startOfDay(date) as CVarArg
        )
        do {
            let logs = try viewContext.fetch(request)
            logs.forEach { viewContext.delete($0) }
            save()
        } catch {
            print("failed to delete skip log: \(error)")
        }
    }

    func deleteGeneratedBlockForDate(routineId: UUID?, date: Date) {
        guard let routineId else { return }
        let request: NSFetchRequest<TimeBlock> = TimeBlock.fetchRequest()
        let startOfDay = DateHelper.shared.startOfDay(date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(
            format: "isGeneratedFromRoutine == YES AND sourceRoutineID == %@ AND date >= %@ AND date < %@",
            routineId as CVarArg,
            startOfDay as CVarArg,
            endOfDay as CVarArg
        )
        do {
            let blocks = try viewContext.fetch(request)
            blocks.forEach { viewContext.delete($0) }
            save()
        } catch {
            print("failed to delete generated block for date: \(error)")
        }
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

