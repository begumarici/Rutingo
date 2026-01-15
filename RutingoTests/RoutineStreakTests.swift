//
//  RoutineStreakTests.swift
//  RutingoTests
//
//  Created by Begüm Arıcı on 15.11.2025.
//

import XCTest
@testable import Rutingo
import CoreData

@MainActor
final class RoutineStreakTests: XCTestCase {
    
    var context: NSManagedObjectContext!
    var routine: Routine!

    override func setUpWithError() throws {
        let container = NSPersistentContainer(name: "Rutingo")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { description, error in
            XCTAssertNil(error)
        }
        
        context = container.viewContext
        
        routine = Routine(context: context)
        routine.id = UUID()
        routine.name = "Test Routine"
        routine.createdAt = Date()
        routine.lastFrequencyChangeDate = DateHelper.shared.startOfDay(Date())
        routine.frequency = .daily
    }
    
    // MARK: - Basic Counting Tests
    func testCurrentStreak_NoCompletions_ReturnsZero() {
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 0, "Streak should be zero if there are no completions.")
    }
    
    func testCurrentStreak_CompletedToday_ReturnsOne() {
        addCompletion(daysAgo: 0)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 1)
    }
    
    func testCurrentStreak_CompletedFor2Days_ReturnsTwo() {
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 1)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 2)
    }
    
    func testCurrentStreak_CompletedFor3Days_ReturnsThree() {
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 1)
        addCompletion(daysAgo: 2)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 3)
    }
    
    func testCurrentStreak_MissedYesterday_ResetsStreak() {
        // Today exists, yesterday missing, day before exists -> Streak should be 1 (Only today)
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 2)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 1, "Streak should break if yesterday was missed.")
    }
    
    func testCurrentStreak_NotCompletedToday_CountsYesterday() {
        // Not completed today but completed yesterday -> Streak continues (not broken yet)
        addCompletion(daysAgo: 1)
        addCompletion(daysAgo: 2)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 2, "Should count from yesterday if not completed today.")
    }
    
    func testCurrentStreak_TwoDaysMissed_ReturnsZero() {
        addCompletion(daysAgo: 2)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 0, "Streak should reset if two consecutive days are missed.")
    }
    
    // MARK: - Logic Tests
    func testCurrentStreak_SpecificDays_SkipsNonScheduledDays() {
        let today = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let todayWeekday = Calendar.current.component(.weekday, from: today)
        let twoDaysAgoWeekday = Calendar.current.component(.weekday, from: twoDaysAgo)
        
        // Rule: Only Today and 2 Days Ago. (Yesterday automatically becomes a REST day)
        routine.frequency = .specificDays([todayWeekday, twoDaysAgoWeekday])
    
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 2)
        
        XCTAssertEqual(routine.currentStreak, 2, "Non-scheduled days (rest days) should be skipped and streak preserved.")
    }
    
    // MARK: - Milestone / Frequency Change Tests
    func testStreak_FrequencyChange_DoesNotFixPastFailures() {
        // In the past, it was required "daily" but was not done.
        // Relaxing the rule today should not save the past.
        
        // 1. Completed two days ago (with daily rule)
        addCompletion(daysAgo: 2, withSnapshot: .daily)
        
        // 2. Yesterday WAS MISSED. (Required due to Daily -> Streak Broken)
        
        // 3. Changed rule today. Milestone is now Today.
        simulateFrequencyChange(to: .specificDays([6]), daysAgo: 0)
        
        XCTAssertEqual(routine.currentStreak, 0, "New rule should not cover up past failures.")
    }
    
    func testStreak_FrequencyChange_PreservesValidGaps() {
        // past: rule was only 1 day a week.
        // today: rule becomes every day.
        // the gap in the past was a valid holiday, so streak should continue.
        
        // find which day of the week 2 days ago.
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let weekday = Calendar.current.component(.weekday, from: twoDaysAgo)
        
        // 1. Complete task 2 days ago (Snapshot: Rule was "Only This Day")
        addCompletion(daysAgo: 2, withSnapshot: .specificDays([weekday]))
        
        // 2. Yesterday is skipped (It was a valid Rest Day under the old rule)
        
        // 3. Today: User switches to "Daily" and completes the task
        simulateFrequencyChange(to: .daily, daysAgo: 0)
        addCompletion(daysAgo: 0, withSnapshot: .daily)
        
        // Result: Streak should be 2 (Today + 2 Days Ago). Yesterday is skipped, not broken.
        XCTAssertEqual(routine.currentStreak, 2, "Valid past gaps (rest days) should be preserved.")
    }

    override func tearDownWithError() throws {
        context = nil
        routine = nil
    }

    // MARK: - Helpers
    func addCompletion(daysAgo: Int) {
        addCompletion(daysAgo: daysAgo, withSnapshot: routine.frequency)
    }
    
    func addCompletion(daysAgo: Int, withSnapshot frequency: Frequency) {
        let completion = RoutineCompletion(context: context)
        completion.id = UUID()
        
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())
        completion.date = DateHelper.shared.startOfDay(date!)
        completion.routine = routine
        
        completion.frequencySnapshot = try? JSONEncoder().encode(frequency)
    }

    func simulateFrequencyChange(to newFrequency: Frequency, daysAgo: Int) {
        routine.frequency = newFrequency
        let changeDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
        routine.lastFrequencyChangeDate = DateHelper.shared.startOfDay(changeDate)
    }
}
