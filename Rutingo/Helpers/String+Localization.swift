//
//  String+Localization.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 10.01.2026.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
