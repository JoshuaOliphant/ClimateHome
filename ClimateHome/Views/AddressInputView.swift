// ABOUTME: Address text field with MapKit autocomplete suggestions
// ABOUTME: Supports keyboard submit, button tap, and suggestion selection

import SwiftUI

struct AddressInputView: View {
    @Binding var address: String
    let isLoading: Bool
    let searchService: AddressSearchService
    let onSubmit: () -> Void
    let onSelectResult: (AddressSearchResult) -> Void

    @FocusState private var isTextFieldFocused: Bool

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
                    .focused($isTextFieldFocused)
                    .onChange(of: address) { _, newValue in
                        searchService.search(query: newValue)
                    }

                Button(action: onSubmit) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading || address.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Autocomplete suggestions dropdown
            if !searchService.searchResults.isEmpty && isTextFieldFocused && !isLoading {
                suggestionsDropdown
            }
        }
    }

    private var suggestionsDropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(searchService.searchResults) { result in
                Button {
                    selectResult(result)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.title)
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        if !result.subtitle.isEmpty {
                            Text(result.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                if result.id != searchService.searchResults.last?.id {
                    Divider()
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }

    private func selectResult(_ result: AddressSearchResult) {
        address = result.fullAddress
        searchService.clearResults()
        isTextFieldFocused = false
        onSelectResult(result)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var address = ""
        @State private var searchService = AddressSearchService()

        var body: some View {
            AddressInputView(
                address: $address,
                isLoading: false,
                searchService: searchService,
                onSubmit: {},
                onSelectResult: { _ in }
            )
            .padding()
        }
    }
    return PreviewWrapper()
}
