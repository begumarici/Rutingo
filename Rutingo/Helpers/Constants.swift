//
//  Constants.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.11.2025.
//

import UIKit

enum AppColors {
    static let background = UIColor.systemBackground
    static let cardBackground = UIColor.secondarySystemBackground
    static let primary = UIColor.label
    static let secondary = UIColor.secondaryLabel
    static let accent = UIColor.systemGreen
}

enum AppFonts {
    static func regular(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .regular)
    }
    
    static func medium(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .medium)
    }
    
    static func semibold(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .semibold)
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .bold)
    }
}

enum Layout {
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
}
 
