import Foundation
import SwiftUI

struct HeaderView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .foregroundColor(.theme.accent)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.theme.accent.opacity(0.2), lineWidth: 2)
                )
            
            VStack(alignment: .leading) {
                Text("Hoşgeldiniz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Image(systemName: "bell.fill")
                .font(.title2)
                .foregroundColor(.theme.accent)
                .padding(8)
                .background(Color.theme.accent.opacity(0.2))
                .clipShape(Circle())
        }
        .padding(.horizontal)
    }
} 
