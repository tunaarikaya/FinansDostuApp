import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color(.systemBackground)
    let green = Color("CustomGreen")
    let red = Color("CustomRed")
    let orange = Color("CustomOrange")
    let secondaryText = Color(.secondaryLabel)
} 