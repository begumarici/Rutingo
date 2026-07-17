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

    func fetchAllRoutines() -> [Routine] {
        return dataManager.fetchAllRoutines()
    }

    func routine(withID id: UUID) -> Routine? {
        return dataManager.fetchAllRoutines().first { $0.id == id }
    }
    
    func addBlock(title: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, linkedRoutine: Routine? = nil, completion: () -> Void) {
        
        let block = dataManager.saveBlock(
            title: title, startHour: startHour, startMinute: startMinute,
            endHour: endHour, endMinute: endMinute, date: selectedDate
        )
        if let routine = linkedRoutine {
            dataManager.addRoutineToBlock(routine, block: block)
        }
        loadData(completion: completion)
    }
    
    func updateBlock(_ block: TimeBlock, title: String, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, completion: () -> Void) {
        block.title = title
        block.startHour = Int16(startHour)
        block.startMinute = Int16(startMinute)
        block.endHour = Int16(endHour)
        block.endMinute = Int16(endMinute)
        dataManager.save()
        loadData(completion: completion)
    }
    
    func updateBlockWithRoutine(_ block: TimeBlock, title: String,
                                 startHour: Int, startMinute: Int,
                                 endHour: Int, endMinute: Int,
                                 newLinkedRoutine: Routine?,
                                 completion: () -> Void) {
        block.title = title
        block.startHour = Int16(startHour)
        block.startMinute = Int16(startMinute)
        block.endHour = Int16(endHour)
        block.endMinute = Int16(endMinute)

        for routine in block.linkedRoutines {
            dataManager.removeRoutineFromBlock(routine, block: block)
        }

        if let routine = newLinkedRoutine {
            dataManager.addRoutineToBlock(routine, block: block)
        }

        dataManager.save()
        loadData(completion: completion)
    }

    func deleteBlock(_ block: TimeBlock, completion: () -> Void) {
        dataManager.deleteBlock(block)
        loadData(completion: completion)
    }

    /// Skipping a future routine occurrence is disabled for now — see YAMA NOTLARI: to support it
    /// properly, unskip needs to be reachable before the day arrives (Today only shows the skipped
    /// section for today/past, and Blocks has no "skipped" state UI at all today). Revisit later.
    func skipBlock(_ block: TimeBlock, completion: () -> Void) {
        guard let date = block.date, date <= DateHelper.shared.startOfDay() else {
            completion()
            return
        }
        if let routineID = block.sourceRoutineID {
            dataManager.saveSkipLog(routineId: routineID, date: date, reason: "skipped_from_block")
        }
        deleteBlock(block, completion: completion)
    }

    func linkRoutine(_ routine: Routine, to block: TimeBlock, completion: () -> Void) {
        dataManager.addRoutineToBlock(routine, block: block)
        loadData(completion: completion)
    }

    func unlinkRoutine(_ routine: Routine, from block: TimeBlock, completion: () -> Void) {
        dataManager.removeRoutineFromBlock(routine, block: block)
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

    func duration(for block: TimeBlock) -> String {
        let totalMinutes = Int(block.endHour) * 60 + Int(block.endMinute)
                         - Int(block.startHour) * 60 - Int(block.startMinute)
        guard totalMinutes > 0 else { return "" }
        let hours   = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours) \("hour".localized) \(minutes) \("minute".localized)"
        } else if hours > 0 {
            return "\(hours) \("hour".localized)"
        } else {
            return "\(minutes) \("minute".localized)"
        }
    }
}
