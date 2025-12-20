// ABOUTME: Displays list of saved property addresses with risk levels
// ABOUTME: Supports swipe-to-delete and shows risk comparison data

import SwiftUI
import SwiftData

struct SavedAddressesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedAddress.savedAt, order: .reverse) private var savedAddresses: [SavedAddress]

    var body: some View {
        Group {
            if savedAddresses.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(savedAddresses) { address in
                        SavedAddressRow(address: address)
                    }
                    .onDelete(perform: deleteAddresses)
                }
            }
        }
        .navigationTitle("Saved Properties")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Saved Properties")
                .font(.headline)

            Text("Save properties from search results to compare climate risks")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteAddresses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(savedAddresses[index])
        }
    }
}

struct SavedAddressRow: View {
    let address: SavedAddress

    private var overallRiskLevel: RiskLevel {
        RiskLevel(rawValue: address.overallRiskLevel) ?? .unknown
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let nickname = address.nickname, !nickname.isEmpty {
                        Text(nickname)
                            .font(.headline)
                    }

                    Text(address.formattedAddress ?? address.address)
                        .font(address.nickname != nil ? .subheadline : .headline)
                        .foregroundStyle(address.nickname != nil ? .secondary : .primary)
                }

                Spacer()

                Label(overallRiskLevel.rawValue, systemImage: overallRiskLevel.systemImage)
                    .font(.caption.bold())
                    .foregroundStyle(overallRiskLevel.color)
            }

            HStack(spacing: 16) {
                if let wildfire = address.wildfireRiskLevel {
                    riskChip(title: "Fire", level: RiskLevel(rawValue: wildfire) ?? .unknown)
                }
                if let flood = address.floodRiskLevel {
                    riskChip(title: "Flood", level: RiskLevel(rawValue: flood) ?? .unknown)
                }
                if let earthquake = address.earthquakeRiskLevel {
                    riskChip(title: "Quake", level: RiskLevel(rawValue: earthquake) ?? .unknown)
                }
                if let volcano = address.volcanoRiskLevel {
                    riskChip(title: "Volcano", level: RiskLevel(rawValue: volcano) ?? .unknown)
                }
                if let air = address.airQualityRiskLevel {
                    riskChip(title: "Air", level: RiskLevel(rawValue: air) ?? .unknown)
                }
            }

            Text("Saved \(address.savedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func riskChip(title: String, level: RiskLevel) -> some View {
        HStack(spacing: 2) {
            Text(title)
            Circle()
                .fill(level.color)
                .frame(width: 8, height: 8)
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(level.color.opacity(0.1))
        .cornerRadius(4)
    }
}

#Preview("With Saved Addresses") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavedAddress.self, configurations: config)

    let address1 = SavedAddress(
        address: "700 5th Ave, Seattle",
        formattedAddress: "700 5TH AVE, SEATTLE, WA 98104",
        latitude: 47.6062,
        longitude: -122.3321,
        wildfireRiskLevel: "Low",
        floodRiskLevel: "Low",
        earthquakeRiskLevel: "High",
        volcanoRiskLevel: "Low",
        airQualityRiskLevel: "Low",
        overallRiskLevel: "High"
    )

    let address2 = SavedAddress(
        address: "1234 Forest Rd, Cle Elum",
        formattedAddress: "1234 FOREST RD, CLE ELUM, WA 98922",
        latitude: 47.2,
        longitude: -120.9,
        nickname: "Mountain Cabin",
        wildfireRiskLevel: "Very High",
        floodRiskLevel: "Moderate",
        earthquakeRiskLevel: "Low",
        volcanoRiskLevel: "Low",
        airQualityRiskLevel: "Moderate",
        overallRiskLevel: "Very High"
    )

    container.mainContext.insert(address1)
    container.mainContext.insert(address2)

    return NavigationStack {
        SavedAddressesView()
            .modelContainer(container)
    }
}

#Preview("Empty State") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SavedAddress.self, configurations: config)

    return NavigationStack {
        SavedAddressesView()
            .modelContainer(container)
    }
}
