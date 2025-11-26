//
//  Constants.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.11.2025.
//

import UIKit

enum AppColors {
    static let background = UIColor(red: 37/255, green: 37/255, blue: 37/255, alpha: 1.0)
    static let cardBackground = UIColor.secondarySystemBackground
    static let primary = UIColor.white
    static let secondary = UIColor.lightGray
    static let accent = UIColor.systemGreen
}

enum AppFonts {
    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "FiraSans-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
    }
    
    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "FiraSans-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }
    
    static func semibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "FiraSans-SemiBold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
    }
    
    static func bold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "FiraSans-Bold", size: size) ?? .systemFont(ofSize: size, weight: .bold)
    }
}

enum Layout {
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
}
 
