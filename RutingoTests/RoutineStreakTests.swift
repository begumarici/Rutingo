//
//  RuoutineStreakTests.swift
//  RutingoTests
//
//  Created by Begüm Arıcı on 15.11.2025.
//

import XCTest
@testable import Rutingo
import CoreData

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
        routine.frequency = .daily
    }
    
    func testCurrentStreak_NoCompletions_ReturnsZero() {
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 0, "streak should be zero if there is no completion")
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
        addCompletion(daysAgo: 0)
        addCompletion(daysAgo: 2)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 1, "streak should reset when a day is missed")
    }
    
    func testCurrentStreak_NotCompletedToday_CountsYesterday() {
        addCompletion(daysAgo: 1)
        addCompletion(daysAgo: 2)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 2, "streak should count from yesterday if today not completed")
    }
    
    func testCurrentStreak_TwoDaysMissed_ReturnsZero() {
        addCompletion(daysAgo: 2)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 0, "streak should be zero when two consecutive days missed")
    }
    
    func testCurrentStreak_SpecificDays_SkipsNonScheduledDays() {
        // BEFORE RUN THIS TEST, ADJUST THE DATE TO TODAY!
        routine.frequency = .specificDays([1,2])
        addCompletion(on: date(day: 7, month: 12))
        addCompletion(on: date(day: 8, month: 12))
        addCompletion(on: date(day: 14, month: 12))
        addCompletion(on: date(day: 15, month: 12))
        
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 4, "should skip non-scheduled days")
    }
    
    // MARK: - Frequency Change Tests
    func testCurrentStreak_FrequencyChanged_PreservesStreak() {
        addCompletion(daysAgo: 2)
        addCompletion(daysAgo: 1)
        routine.frequency = .specificDays([3,4])
        addCompletion(daysAgo: 0)
        let streak = routine.currentStreak
        XCTAssertEqual(streak, 3, "streak should be preserved even frequency changes")
    }
    
    func testBestStreak_FrequencyChanged_PreservesBestStreak() {
        addCompletion(on: date(day: 10, month: 12))
        addCompletion(on: date(day: 11, month: 12))
        addCompletion(on: date(day: 12, month: 12))
        
        routine.frequency = .specificDays([1,2])
        
        addCompletion(on: date(day: 14, month: 12))
        addCompletion(on: date(day: 15, month: 12))
        
        let best = routine.bestStreak
        XCTAssertEqual(best, 5, "best streak should be preserved")
    }

    override func tearDownWithError() throws {
        context = nil
        routine = nil
    }

    // MARK: - Helpers
    func addCompletion(daysAgo: Int) {
        let completion = RoutineCompletion(context: context)
        completion.id = UUID()
        
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())
        completion.date = DateHelper.shared.startOfDay(date!)
        completion.routine = routine
    }
    
    func addCompletion(on date: Date) {
        let completion = RoutineCompletion(context: context)
        completion.id = UUID()
        completion.date = DateHelper.shared.startOfDay(date)
        completion.routine = routine
    }
    
    func date(day: Int, month: Int, year: Int = 2025) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        return Calendar.current.date(from: components)!
    }
}
