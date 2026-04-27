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
    static let secondaryCardBackground = UIColor.tertiarySystemBackground
    static let navbarTitle = UIColor.label
    static let primary = UIColor.label
    static let secondary = UIColor.secondaryLabel
    static let tertiary = UIColor.tertiaryLabel
    
    static let progressEmpty = UIColor(red: 187/255, green: 197/255, blue: 189/255, alpha: 1.0)
    static let progressLow = UIColor(red: 142/255, green: 177/255, blue: 149/255, alpha: 1.0)
    static let progressMedium = UIColor(red: 91/255, green: 131/255, blue: 100/255, alpha: 1.0)
    static let progressHigh = UIColor(red: 56/255, green: 113/255, blue: 69/255, alpha: 1.0)
    static let progressComplete = UIColor(red: 31/255, green: 85/255, blue: 43/255, alpha: 1.0)
    
    // Feeling
    static let feelingEnergy    = UIColor(hex: "4A7C20")
    static let feelingHard      = UIColor(hex: "C94B1A")
    static let feelingBoring    = UIColor(hex: "888780")
    static let feelingDeep      = UIColor(hex: "4A43A0")

    // Priority
    static let priorityMust     = UIColor(hex: "C94B1A")
    static let priorityMaybe    = UIColor(hex: "D08A10")
    static let prioritySomeday  = UIColor(hex: "C0BFBB")

    // Gradient
    static let gradientPink     = UIColor(hex: "FCE4F0")
    static let gradientYellow   = UIColor(hex: "FFF7D6")
    static let gradientPeach    = UIColor(hex: "FFE4D6")
    static let gradientLavender = UIColor(hex: "EDE4FE")
    static let gradientMint     = UIColor(hex: "DCF5EA")

    // Accent & UI
    static let accent            = UIColor(hex: "FF6B9D")
    static let separator         = UIColor(hex: "F0F0F0")
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
    static let blockRadius: CGFloat = 12
    static let chipRadius:  CGFloat = 20
}
 
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
