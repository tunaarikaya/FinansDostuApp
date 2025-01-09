import SwiftUI

struct BalanceCard: View {
    let balance: Double
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Toplam Bakiye")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .textCase(.uppercase)
                
                Text(String(format: "%.2f ₺", balance))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
                    .animation(.spring(), value: balance)
            }
            
            Spacer()
            
            Image(systemName: "creditcard.fill")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.8),
                            Color.blue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 5)
    }
} 