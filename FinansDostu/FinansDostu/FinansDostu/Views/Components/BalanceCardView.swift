import SwiftUI

struct BalanceCardView: View {
    let balance: Double
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: isAnimating)
                
                Text("Toplam Bakiye")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            
            Text(String(format: "%.2f ₺", balance))
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color.theme.accent,
                    Color.theme.accent.opacity(0.8),
                    Color.theme.accent.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.theme.accent.opacity(0.3), radius: 15, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            isAnimating = true
        }
        .onChange(of: balance) { oldValue, newValue in
            isAnimating.toggle()
        }
    }
} 
