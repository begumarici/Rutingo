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

    // MARK: - isCompletedToday / isScheduledToday
    func testIsCompletedToday_NoCompletion_ReturnsFalse() {
        XCTAssertFalse(routine.isCompletedToday)
    }

    func testIsCompletedToday_HasCompletionToday_ReturnsTrue() {
        addCompletion(daysAgo: 0)
        XCTAssertTrue(routine.isCompletedToday)
    }

    func testIsScheduledToday_Daily_ReturnsTrue() {
        routine.frequency = .daily
        XCTAssertTrue(routine.isScheduledToday)
    }

    func testIsScheduledToday_SpecificDaysNotIncludingToday_ReturnsFalse() {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        let otherDay = todayWeekday == 1 ? 2 : 1
        routine.frequency = .specificDays([otherDay])
        XCTAssertFalse(routine.isScheduledToday)
    }

    // MARK: - wasScheduled
    func testWasScheduled_DailyFrequency_TrueForAnyDay() {
        routine.frequency = .daily
        let someDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        XCTAssertTrue(routine.wasScheduled(on: someDate))
    }

    func testWasScheduled_SpecificDays_FalseOnNonMatchingDay() {
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let weekday = Calendar.current.component(.weekday, from: twoDaysAgo)
        let nonMatchingDay = weekday == 1 ? 2 : 1
        routine.frequency = .specificDays([nonMatchingDay])
        XCTAssertFalse(routine.wasScheduled(on: twoDaysAgo))
    }

    func testWasScheduled_UsesCompletionSnapshot_WhenCompletionExistsForDate() {
        // Rule today is "daily", but the completion 2 days ago was snapshotted under a
        // restrictive rule that didn't include that weekday — snapshot should win.
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        let weekday = Calendar.current.component(.weekday, from: twoDaysAgo)
        let otherDay = weekday == 1 ? 2 : 1

        addCompletion(daysAgo: 2, withSnapshot: .specificDays([otherDay]))
        routine.frequency = .daily

        XCTAssertFalse(routine.wasScheduled(on: twoDaysAgo), "Completion's frequency snapshot should determine scheduling for that day.")
    }

    // MARK: - bestStreak
    func testBestStreak_NoCompletions_ReturnsZero() {
        XCTAssertEqual(routine.bestStreak, 0)
    }

    func testBestStreak_ConsecutiveCompletions_ReturnsFullLength() {
        routine.createdAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 1)
        addCompletion(daysAgo: 2)
        XCTAssertEqual(routine.bestStreak, 3)
    }

    func testBestStreak_BrokenInMiddle_ReturnsLongestRun() {
        routine.createdAt = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        // completed days 4,3 ago, missed day 2 ago, completed days 1,0 ago
        addCompletion(daysAgo: 4)
        addCompletion(daysAgo: 3)
        addCompletion(daysAgo: 1)
        addCompletion(daysAgo: 0)
        XCTAssertEqual(routine.bestStreak, 2)
    }

    func testBestStreak_SkippedDayDoesNotBreakStreak() {
        routine.createdAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        addCompletion(daysAgo: 2)
        // day 1 ago is skipped (no completion, not asserted here since isSkipped reads
        // from the real CoreDataManager singleton; this case only verifies a plain gap
        // without a skip log breaks the run instead of being preserved).
        addCompletion(daysAgo: 0)
        XCTAssertEqual(routine.bestStreak, 1, "Without an actual skip log, a missed day breaks the run.")
    }

    func testBestStreak_NonScheduledDaysAreIgnored() {
        let today = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let todayWeekday = Calendar.current.component(.weekday, from: today)
        let twoDaysAgoWeekday = Calendar.current.component(.weekday, from: twoDaysAgo)

        routine.createdAt = twoDaysAgo
        routine.frequency = .specificDays([todayWeekday, twoDaysAgoWeekday])
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 2)

        XCTAssertEqual(routine.bestStreak, 2, "Rest days shouldn't break the best streak run.")
    }

    // MARK: - completionRate
    func testCompletionRate_NoScheduledDays_ReturnsZero() {
        let today = Calendar.current.component(.weekday, from: Date())
        let other = today == 1 ? 2 : 1
        routine.createdAt = Date()
        routine.frequency = .specificDays([other])
        XCTAssertEqual(routine.completionRate, 0)
    }

    func testCompletionRate_AllScheduledDaysCompleted_Returns100() {
        routine.createdAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        routine.frequency = .daily
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 1)
        addCompletion(daysAgo: 2)
        XCTAssertEqual(routine.completionRate, 100)
    }

    func testCompletionRate_PartialCompletion_ReturnsProportionalRate() {
        routine.createdAt = Calendar.current.date(byAdding: .day, value: -3, to: Date())
        routine.frequency = .daily
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 1)
        // 2 of 4 scheduled days completed -> 50%
        XCTAssertEqual(routine.completionRate, 50)
    }

    // MARK: - missedScheduledDay
    func testMissedScheduledDay_AllDaysCompleted_ReturnsFalse() {
        routine.createdAt = Calendar.current.date(byAdding: .day, value: -3, to: Date())
        routine.frequency = .daily
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 1)
        addCompletion(daysAgo: 2)
        addCompletion(daysAgo: 3)

        let start = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let end = Date()
        XCTAssertFalse(routine.missedScheduledDay(between: start, and: end))
    }

    func testMissedScheduledDay_GapInBetween_ReturnsTrue() {
        routine.createdAt = Calendar.current.date(byAdding: .day, value: -3, to: Date())
        routine.frequency = .daily
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 3)
        // day -1 and -2 are missed

        let start = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let end = Date()
        XCTAssertTrue(routine.missedScheduledDay(between: start, and: end))
    }

    // MARK: - frequency get/set roundtrip
    func testFrequency_DefaultsToDailyWhenNoData() {
        routine.frequencyData = nil
        if case .daily = routine.frequency {
            // expected
        } else {
            XCTFail("Expected daily frequency as default")
        }
    }

    func testFrequency_RoundTripsSpecificDays() {
        routine.frequency = .specificDays([2, 4, 6])
        if case .specificDays(let days) = routine.frequency {
            XCTAssertEqual(days, [2, 4, 6])
        } else {
            XCTFail("Expected specificDays frequency")
        }
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
