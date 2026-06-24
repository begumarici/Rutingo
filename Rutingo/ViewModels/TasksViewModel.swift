//
//  TasksViewModel.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 21.05.2026.
//

import Foundation
import CoreData

class TasksViewModel {

    private let context = CoreDataManager.shared.viewContext

    private(set) var activeTasks: [Task] = []
    private(set) var completedTasks: [Task] = []

    func fetchTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "isCompleted", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            let tasks = try context.fetch(request)
            activeTasks = tasks.filter { !$0.isCompleted }
            completedTasks = tasks.filter { $0.isCompleted }
        } catch {
            print("Failed to fetch tasks:", error)
        }
    }

    func addTask(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let task = Task(context: context)
        task.id = UUID()
        task.title = trimmedTitle
        task.createdAt = Date()
        task.isCompleted = false
        task.category = "general"
        task.priority = "normal"

        saveAndRefresh()
    }

    func toggleTask(_ task: Task) {
        task.isCompleted.toggle()
        task.completedAt = task.isCompleted ? Date() : nil
        saveAndRefresh()
    }

    func deleteTask(_ task: Task) {
        context.delete(task)
        saveAndRefresh()
    }

    private func saveAndRefresh() {
        do {
            try context.save()
            fetchTasks()
        } catch {
            print("Failed to save task:", error)
        }
    }
}
