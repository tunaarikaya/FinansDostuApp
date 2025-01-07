import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var addAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Arama Alanı
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Ara", text: $searchText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .frame(minWidth: 30)
            
            // Harcama Ekleme Butonu
            Button(action: addAction) {
                HStack {
                    Image(systemName: "plus")
                    Text("Ekle")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.theme.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 2)
            }
        }
        .padding(.horizontal)
    }
} 
