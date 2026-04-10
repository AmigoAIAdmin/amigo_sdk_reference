import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                NavigationLink {
                    FaceSwapView()
                } label: {
                    Label("Swap Face on Image", systemImage: "face.smiling")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 40)
                Spacer()
            }
            .navigationTitle("Amigo SDK")
        }
    }
}
