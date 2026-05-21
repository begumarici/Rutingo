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
    var selectedDate: Date = DateHelper.shared.startOfDay()
    
    // MARK: - Init
    init(dataManager: DataManager = CoreDataManager.shared) {
        self.dataManager = dataManager
    }
    
    // MARK: - Data
    func loadData(completion: () -> Void) {
        blocks = dataManager.fetchBlocks(for: selectedDate)
        completion()
    }
    
    func addBlock(title: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, completion: () -> Void) {
        _ = dataManager.saveBlock(title: title, startHour: startHour, startMinute: startMinute, endHour: endHour, endMinute: endMinute, date: selectedDate)
        loadData(completion: completion)
    }
    
    func updateBlock(_ block: TimeBlock, title: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, completion: () -> Void) {
        block.title = title
        block.startHour = Int16(startHour)
        block.startMinute = Int16(startMinute)
        block.endHour = Int16(endHour)
        block.endMinute = Int16(endMinute)
        CoreDataManager.shared.save()
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
}
