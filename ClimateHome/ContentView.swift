// ABOUTME: Root view containing address input and results display
// ABOUTME: Single-screen PoC layout for climate risk lookup

import SwiftUI

struct ContentView: View {
    @State private var viewModel = RiskLookupViewModel(airNowAPIKey: "3EF833EE-DEEE-49AC-89A4-6512A20E0838")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    AddressInputView(
                        address: $viewModel.addressInput,
                        isLoading: viewModel.isLoading,
                        searchService: viewModel.addressSearchService,
                        onSubmit: {
                            Task { await viewModel.performLookup() }
                        },
                        onSelectResult: { result in
                            viewModel.selectSearchResult(result)
                            Task { await viewModel.performLookup() }
                        }
                    )

                    if let error = viewModel.errorMessage {
                        ErrorBannerView(message: error)
                    }

                    if viewModel.isLoading {
                        LoadingView()
                    }

                    if let report = viewModel.currentReport {
                        RiskResultsView(report: report)
                    }
                }
                .padding()
            }
            .navigationTitle("ClimateHome")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "house.and.flag.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)

            Text("Washington State Climate Risk Tool")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Check flood, wildfire, earthquake, and air quality risks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
}

#Preview {
    ContentView()
}
