//
//  RoutineCompletion+Extension.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 14.12.2025.
//

import Foundation

extension RoutineCompletion {
    var frequency: Frequency {
        guard let data = frequencySnapshot else { return.daily }
        return (try? JSONDecoder().decode(Frequency.self, from: data)) ?? .daily
    }
}
