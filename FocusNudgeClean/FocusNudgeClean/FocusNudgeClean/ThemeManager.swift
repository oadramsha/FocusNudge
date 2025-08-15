//
//  ThemeManager.swift
//  FocusNudgeClean
//
//  Created by Ramsha Oad on 2025-07-14.
//
import SwiftUI
class ThemeManager {
    static let shared = ThemeManager()

    func getColor(named name: String) -> Color {
        switch name {
        case "Purple": return .purple
        case "Blue": return .blue
        case "Green": return .green
        case "Orange": return .orange
        default: return .purple
        }
    }

    func getUIColor(named name: String) -> UIColor {
        switch name {
        case "Purple": return UIColor.purple
        case "Blue": return UIColor.systemBlue
        case "Green": return UIColor.systemGreen
        case "Orange": return UIColor.orange
        default: return UIColor.purple
        }
    }
}

