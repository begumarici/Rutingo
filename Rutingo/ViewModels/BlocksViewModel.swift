//
//  BlocksViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 28.04.2026.
//

import Foundation

class BlocksViewModel {
    
    // MARK: - Properties
    private let dataManager: DataManager
    var blocks: [TimeBlock] = []
    
    // MARK: - Init
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Data
    func loadData(completion: () -> Void) {
        blocks = dataManager.fetchAllBlocks()
        if blocks.isEmpty {
            createDefaultBlocks()
        }
        completion()
    }
    
    func addBlock(title: String, startHour: Int, endHour: Int, completion: () -> Void) {
        _ = dataManager.saveBlock(title: title, startHour: startHour, endHour: endHour)
        loadData(completion: completion)
    }

    func deleteBlock(_ block: TimeBlock, completion: () -> Void) {
        dataManager.deleteBlock(block)
        loadData(completion: completion)
    }

    func addRoutine(_ routine: Routine, to block: TimeBlock, completion: () -> Void) {
        dataManager.addRoutineToBlock(routine, block: block)
        loadData(completion: completion)
    }

    func removeRoutine(_ routine: Routine, from block: TimeBlock, completion: () -> Void) {
        dataManager.removeRoutineFromBlock(routine, block: block)
        loadData(completion: completion)
    }
    
    // MARK: - Computed
    var headerSubtitle: String {
        let count = blocks.count
        return "\(count) \("blocks_count".localized)"
    }
    
    // MARK: - Helpers
    private func createDefaultBlocks() {
        _ = dataManager.saveBlock(title: "morning_block".localized, startHour: 6,  endHour: 9)
        _ = dataManager.saveBlock(title: "deep_work_block".localized, startHour: 9,  endHour: 12)
        _ = dataManager.saveBlock(title: "afternoon_block".localized, startHour: 13, endHour: 17)
        _ = dataManager.saveBlock(title: "evening_block".localized, startHour: 20, endHour: 22)
        blocks = dataManager.fetchAllBlocks()
    }
}
