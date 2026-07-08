//
//  Constants.swift
//  Rutingo
//
//  Created by Begüm Arıcı on 19.11.2025.
//

import UIKit

enum AppColors {
    // MARK: - Base surfaces
    static let background = UIColor.dynamic(light: "F5F5F7", dark: "1C1B22")
    static let cardBackground = UIColor.dynamic(light: "FFFFFF", dark: "26242E")
    static let secondaryCardBackground = UIColor.dynamic(light: "EBEBED", dark: "322F3B")
    static let border = UIColor.dynamic(light: "ECE8E2", dark: "3A3744")

    // MARK: - Text
    static let navbarTitle = UIColor.dynamic(light: "2B2730", dark: "F5F2F8")
    static let primary = UIColor.dynamic(light: "2B2730", dark: "F5F2F8")
    static let secondary = UIColor.dynamic(light: "9C97A3", dark: "9690A0")
    static let tertiary = UIColor.dynamic(light: "C7C2CB", dark: "6E6A78")

    // MARK: - Accent palette
    static let accentOrange = UIColor.dynamic(light: "FF7A45", dark: "FF8A5C")
    static let accentPurple = UIColor.dynamic(light: "8B5CF6", dark: "A78BFA")
    static let accentGreen  = UIColor.dynamic(light: "34C77B", dark: "4ADE94")

    /// Main call-to-action accent (save buttons, primary actions)
    static let accent = accentPurple

    /// On-color text — used when a label sits on top of an accent-filled
    /// background (e.g. text inside an orange button)
    static let onAccent = UIColor.dynamic(light: "FFFFFF", dark: "1C1B22")

    // MARK: - Tag / pill colors
    // Each pair is (background, text) and is tuned per-mode for contrast.
    static let tagOrangeBackground = UIColor.dynamic(light: "FFE4D6", dark: "4A2C1C")
    static let tagOrangeText       = UIColor.dynamic(light: "B14B1F", dark: "FFB28C")

    static let tagPurpleBackground = UIColor.dynamic(light: "E6DEFB", dark: "352B57")
    static let tagPurpleText       = UIColor.dynamic(light: "5B3FB0", dark: "C7B6FB")

    static let tagGreenBackground  = UIColor.dynamic(light: "DCF5EA", dark: "1F4734")
    static let tagGreenText        = UIColor.dynamic(light: "1E8F5E", dark: "8DEFC0")

    static let tagRedBackground    = UIColor.dynamic(light: "FBE2E1", dark: "4A2323")
    static let tagRedText          = UIColor.dynamic(light: "C23B34", dark: "FF8A80")

    static let tagNeutralBackground = secondaryCardBackground
    static let tagNeutralText       = primary

    // MARK: - Progress (streaks / stats)
    static let progressEmpty = UIColor(red: 187/255, green: 197/255, blue: 189/255, alpha: 1.0)
    static let progressLow = UIColor(red: 142/255, green: 177/255, blue: 149/255, alpha: 1.0)
    static let progressMedium = UIColor(red: 91/255, green: 131/255, blue: 100/255, alpha: 1.0)
    static let progressHigh = UIColor(red: 56/255, green: 113/255, blue: 69/255, alpha: 1.0)
    static let progressComplete = UIColor(red: 31/255, green: 85/255, blue: 43/255, alpha: 1.0)

    // MARK: - Feeling
    static let feelingEnergy    = UIColor(hex: "4A7C20")
    static let feelingHard      = UIColor(hex: "C94B1A")
    static let feelingBoring    = UIColor(hex: "888780")
    static let feelingDeep      = UIColor(hex: "4A43A0")

    // MARK: - Priority
    static let priorityMust     = UIColor(hex: "C94B1A")
    static let priorityMaybe    = UIColor(hex: "D08A10")
    static let prioritySomeday  = UIColor(hex: "C0BFBB")

    // MARK: - Gradient (legacy block backgrounds)
    static let gradientPink     = UIColor(hex: "FCE4F0")
    static let gradientYellow   = UIColor(hex: "FFF7D6")
    static let gradientPeach    = UIColor(hex: "FFE4D6")
    static let gradientLavender = UIColor(hex: "EDE4FE")
    static let gradientMint     = UIColor(hex: "DCF5EA")

    // MARK: - Misc
    static let separator = border
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
    static let cardCornerRadius: CGFloat = 25
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let blockRadius: CGFloat = 12
    static let chipRadius:  CGFloat = 20
    static let pillRadius: CGFloat = 12
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

    /// Returns a color that automatically switches between a light-mode hex
    /// and a dark-mode hex depending on the current `UIUserInterfaceStyle`.
    static func dynamic(light: String, dark: String) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        }
    }
}
