import SwiftUI

struct BalanceCardView: View {
    let balance: Double
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                
                Text("Toplam Bakiye")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Text(String(format: "%.2f ₺", balance))
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.accent, Color.theme.accent.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: Color.theme.accent.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear {
            isAnimating = true
        }
        .onChange(of: balance) { oldValue, newValue in
            isAnimating.toggle()
        }
    }
} 
