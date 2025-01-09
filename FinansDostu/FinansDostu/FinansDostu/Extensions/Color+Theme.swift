import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let accent = Color("AccentColor")
    let background = Color(.systemBackground)
    let secondaryBackground = Color(.secondarySystemBackground)
    
    // Ana renkler
    let primary = Color("CustomBlue")
    let secondary = Color("CustomPurple")
    let success = Color("CustomGreen")
    let warning = Color("CustomOrange")
    let error = Color("CustomRed")
    
    // Metin renkleri
    let primaryText = Color(.label)
    let secondaryText = Color(.secondaryLabel)
    let tertiaryText = Color(.tertiaryLabel)
    
    // Kategori renkleri
    let categoryColors: [Color] = [
        Color("Category1"), // Mavi
        Color("Category2"), // Mor
        Color("Category3"), // Turuncu
        Color("Category4"), // Yeşil
        Color("Category5"), // Pembe
        Color("Category6")  // Turkuaz
    ]
    
    // Gradient renkler
    let gradientStart = Color("GradientStart")
    let gradientEnd = Color("GradientEnd")
    
    // Kart arkaplan renkleri
    let cardBackground = Color(.systemBackground)
    let cardBackgroundSecondary = Color(.secondarySystemBackground)
    
    // Gölge rengi
    let shadowColor = Color.black.opacity(0.1)
    
    // İlerleme çubuğu arkaplan rengi
    let progressBackground = Color(.systemGray5)
} 