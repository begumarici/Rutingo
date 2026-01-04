//
//  Constants.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.11.2025.
//

import UIKit

enum AppColors {
    static let background = UIColor.black
    static let cardBackground = UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 1.0)
    static let primary = UIColor.white
    static let secondary = UIColor.lightGray
    static let tertiary = UIColor.darkGray
    static let accent = UIColor.systemGreen
    
    static let progressEmpty = UIColor(red: 187/255, green: 197/255, blue: 189/255, alpha: 1.0)
    static let progressLow = UIColor(red: 142/255, green: 177/255, blue: 149/255, alpha: 1.0)
    static let progressMedium = UIColor(red: 91/255, green: 131/255, blue: 100/255, alpha: 1.0)
    static let progressHigh = UIColor(red: 56/255, green: 113/255, blue: 69/255, alpha: 1.0)
    static let progressComplete = UIColor(red: 31/255, green: 85/255, blue: 43/255, alpha: 1.0)
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
 
