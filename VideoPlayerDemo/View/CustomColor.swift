//
//  CustomColor.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 31-08-25.
//

import Foundation
import SwiftUICore

struct CustomColor {
    static let viewBackground = Color(hex: "f5f5f5")
    static let gradientOuterColor: Color = Color(hex: "141C1C")
    static let gradientInnerColor: Color = Color(hex: "8697B0").opacity(0.7)
    static let videoCardTitle = Color(hex: "84f6bd")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
