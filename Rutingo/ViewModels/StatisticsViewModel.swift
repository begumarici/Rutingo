//
//  StatisticsViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 29.12.2025.
//

import Foundation

class StatisticsViewModel {
    
    // MARK: - Properties
    private let dataManager: DataManager
    private let statisticsService: StatisticsService

    private var allRoutines: [Routine] = []
    
    // MARK: - Computed Properties
    var lastSevenDays: [Date] {
        return DateHelper.shared.lastSevenDays()
    }
    
    var totalCompletions: Int {
        return statisticsService.getTotalCompletions(from: allRoutines)
    }
    
    var completionRate: Int {
        return statisticsService.getOverallCompletionRate(from: allRoutines)
    }
    
    var activeRoutines: Int {
        return statisticsService.getActiveRoutinesCount(from: allRoutines)
    }
    
    var bestDayOfWeek: String? {
        return statisticsService.getBestDayOfWeek(from: allRoutines)
    }
    
    var overallStreak: Int {
        return statisticsService.getOverallStreak(from: allRoutines)
    }
    
    var dailyCompletionRates: [Int] {
        return statisticsService.getDailyCompletionRates(from: allRoutines)
    }

    var weeklyCompletionRate: Int {
        return statisticsService.getWeeklyCompletionRate(from: allRoutines)
    }
    
    var lastWeekCompletionRate: Int {
        return statisticsService.getLastWeekCompletionRate(from: allRoutines)
    }
    
    // MARK: - Initialization
    init(dataManager: DataManager = CoreDataManager.shared, statisticsService: StatisticsService = StatisticsService()) {
        self.dataManager = dataManager
        self.statisticsService = statisticsService
    }
    
    // MARK: - Data Management
    func loadData(completion: () -> Void) {
        self.allRoutines = dataManager.fetchAllRoutines()
        completion()
    }
    
    func getCompletionProgress() -> [Date: Double] {
        return statisticsService.getWeeklyCompletionProgress(from: allRoutines)
    }
}
