//
//  ThemeManager.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 10.02.2026.
//

import UIKit

enum Theme: String {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system: return "system_theme".localized
        case .light: return "light_theme".localized
        case .dark: return "dark_theme".localized
        }
    }
}

class ThemeManager {
    static let shared = ThemeManager()
    
    private let themeKey = "selectedTheme"
    
    private init() {}
    
    var currentTheme: Theme {
        get {
            guard let themeString = UserDefaults.standard.string(forKey: themeKey),
                  let theme = Theme(rawValue: themeString) else {
                return .system
            }
            return theme
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: themeKey)
            applyTheme(newValue)
        }
    }
    
    func applyTheme(_ theme: Theme) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        switch theme {
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        }
    }
    
    func applySavedTheme() {
        applyTheme(currentTheme)
    }
}
