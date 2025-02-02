import SwiftUI

struct AssetsGridView: View {    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Media.allCases, id: \.self) { asset in
                    VStack {
                        asset.image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)

                        Text(asset.rawValue)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Assets Grid")
    }
}

// Preview
#Preview {
    AssetsGridView()
}
