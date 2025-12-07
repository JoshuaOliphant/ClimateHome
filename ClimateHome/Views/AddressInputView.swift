// ABOUTME: Address text field with search button
// ABOUTME: Supports keyboard submit and button tap

import SwiftUI

struct AddressInputView: View {
    @Binding var address: String
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter a Washington State address")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                TextField("123 Main St, Seattle, WA", text: $address)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.fullStreetAddress)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit(onSubmit)
                    .disabled(isLoading)

                Button(action: onSubmit) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || address.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

#Preview {
    AddressInputView(
        address: .constant("700 5th Ave, Seattle, WA"),
        isLoading: false,
        onSubmit: {}
    )
    .padding()
}
