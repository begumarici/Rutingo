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
    func saveRoutine(
        name: String,
        frequency: Frequency,
        feeling: String?,
        motivation: String?,
        blockType: String?,
        hasReminder: Bool,
        reminderTime: Date?,
        startHour: Int16,
        startMinute: Int16,
        endHour: Int16,
        endMinute: Int16,
        isCountBased: Bool,
        targetValue: Double,
        unit: RoutineUnit
    ) -> Routine
    func deleteRoutine(_ routine: Routine)
    func updateRoutine(
        routine: Routine,
        name: String,
        frequency: Frequency,
        feeling: String?,
        motivation: String?,
        blockType: String?,
        hasReminder: Bool,
        reminderTime: Date?,
        startHour: Int16,
        startMinute: Int16,
        endHour: Int16,
        endMinute: Int16,
        isCountBased: Bool,
        targetValue: Double,
        unit: RoutineUnit
    )
    func toggleCompletion(_ routine: Routine)
    func incrementCompletionCount(_ routine: Routine)
    func decrementCompletionCount(_ routine: Routine)
    func completeCompletionCount(_ routine: Routine)
    func setCompletionValue(_ routine: Routine, value: Double)
    func resetCompletionCount(_ routine: Routine)
    func save()
    func clearAllData()
    
    func fetchBlocks(for date: Date) -> [TimeBlock]
    func saveBlock(
        title: String,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        date: Date
    ) -> TimeBlock
    func deleteBlock(_ block: TimeBlock)
    func addRoutineToBlock(_ routine: Routine, block: TimeBlock)
    func removeRoutineFromBlock(_ routine: Routine, block: TimeBlock)

    func syncGeneratedBlocks(for routine: Routine)
    func deleteGeneratedBlocks(for routine: Routine)
    func deleteGeneratedBlocksFromNow(for routine: Routine)
    func deleteGeneratedBlockForDate(routineId: UUID?, date: Date)
    func fetchAllTasks() -> [Task]
    func saveTask(
        title: String,
        category: String,
        priority: String,
        dueDate: Date?
    ) -> Task
    func toggleTask(_ task: Task)
    func deleteTask(_ task: Task)

    func fetchEvents(for date: Date) -> [Event]
    func saveEvent(title: String, date: Date, time: Date?) -> Event
    func deleteEvent(_ event: Event)

    func saveSkipLog(routineId: UUID, date: Date, reason: String)
    func hasSkipLog(routineId: UUID, date: Date) -> Bool
    func deleteSkipLog(routineId: UUID, date: Date)

    func saveWeeklyReview(weekStartDate: Date, rating: Int, note: String?)
    func hasWeeklyReview(for weekStart: Date) -> Bool
    func fetchAllReviews() -> [WeeklyReview]
}
