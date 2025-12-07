// ABOUTME: Error message banner for displaying API failures
// ABOUTME: Shown when geocoding or other critical operations fail

import SwiftUI

struct ErrorBannerView: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    ErrorBannerView(message: "Address lookup failed: No matching address found")
        .padding()
}
