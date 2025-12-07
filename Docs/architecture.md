# ClimateHome - Technical Architecture

> **Washington State Climate Risk App for Homebuyers**
> Native iOS • Swift/SwiftUI • Paid App ($9.99)

---

## Executive Summary

ClimateHome is a native iOS application that helps Washington State homebuyers understand climate and natural hazard risks for properties they're considering. Unlike existing tools that rely on single proprietary models, ClimateHome aggregates multiple government data sources and presents them in plain English with actionable next steps.

### Key Decisions

| Decision | Choice |
|----------|--------|
| **Geographic Scope** | Washington State (expand later) |
| **Business Model** | One-time purchase ($9.99) |
| **Brand Name** | ClimateHome |
| **Platform** | Native iOS (Swift/SwiftUI) |
| **Minimum iOS Version** | iOS 17.0 |

### Why One-Time Purchase?

- **Usage pattern** - Homebuyers use intensively for 2-6 months, then rarely again
- **Zero API costs** - All government APIs are free (FEMA, WA DNR, EPA, Census)
- **Minimal compute** - iOS app hits APIs directly, no backend needed for core features
- **Better reviews** - Subscription fatigue leads to 1-star reviews for infrequent-use apps
- **Simpler architecture** - No auth, quotas, or subscription management needed

### Market Opportunity

- Zillow removed First Street climate data in December 2024 after CRMLS pressure
- 80%+ of homebuyers want climate risk data (Zillow 2023 survey)
- CarbonPlan study revealed proprietary models disagree significantly
- Washington has unique hazards (Cascadia earthquake, lahars) not covered by national tools
- Homebuyers browse listings on phones - native app provides best UX

---

## Washington State Advantage

Starting with WA provides access to excellent state-level data infrastructure:

| Risk Type | WA-Specific Source | Access Method | National Equivalent |
|-----------|-------------------|---------------|---------------------|
| **Flood** | FEMA NFHL + WA Ecology Risk MAP | ArcGIS REST | Same |
| **Wildfire** | WA DNR WUI Map | ArcGIS MapServer ✅ | USFS (download only) |
| **Air Quality** | Puget Sound Clean Air Agency | Sensor Map | EPA AirNow |
| **Earthquake** | WA DNR Liquefaction Maps | ArcGIS/Download | Limited nationally |
| **Tsunami** | WA DNR Inundation Maps | Portal/Download | Coastal only |
| **Lahar** | Mt. Rainier hazard zones | Portal/Download | N/A (WA unique) |
| **Climate Projections** | UW Climate Impacts Group | Web tool | First Street |

---

## Risk Categories

Given Washington's unique hazard profile, ClimateHome covers **5 risk categories**:

1. 🌊 **Flood Risk** - River flooding, coastal flooding, sea level rise
2. 🔥 **Wildfire Risk** - WUI classification, fire hazard potential
3. 💨 **Air Quality** - Smoke exposure, winter inversions, current AQI
4. 🏔️ **Earthquake Risk** - Liquefaction, fault proximity, Cascadia scenario
5. 🌋 **Volcano Risk** - Mt. Rainier lahar zones (Puget Sound area)

**Differentiator**: First Street doesn't cover earthquake or volcano risks.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      iOS APP (Swift/SwiftUI)                    │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │  Presentation │  │   Domain      │  │    Data       │       │
│  │    Layer      │  │   Layer       │  │    Layer      │       │
│  ├───────────────┤  ├───────────────┤  ├───────────────┤       │
│  │ SwiftUI Views │  │ Use Cases     │  │ API Services  │       │
│  │ ViewModels    │  │ Entities      │  │ Local Storage │       │
│  │ Navigation    │  │ Risk Models   │  │ Keychain      │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  External APIs  │ │  Bundled Data   │ │  SwiftData      │
├─────────────────┤ ├─────────────────┤ ├─────────────────┤
│ • FEMA NFHL     │ │ • Liquefaction  │ │ • Saved addrs   │
│ • WA DNR WUI    │ │ • Lahar zones   │ │ • Search history│
│ • EPA AirNow    │ │ • Tsunami zones │ │ • Cached results│
│ • Census Geocode│ │ (GeoJSON files) │ └─────────────────┘
└─────────────────┘ └─────────────────┘
```

### No Backend Required

The one-time purchase model eliminates the need for a backend:

| Concern | Solution |
|---------|----------|
| Data aggregation | iOS app calls APIs directly in parallel |
| Spatial queries | Bundle GeoJSON files, query client-side |
| API key security | Store in Keychain, obfuscate in binary |
| Data updates | Ship new GeoJSON with app updates |
| User accounts | Not needed - no quotas to track |

---

## iOS App Architecture

### Project Structure

```
ClimateHome/
├── App/
│   ├── ClimateHomeApp.swift
│   └── Configuration/
│       └── APIKeys.swift
│
├── Presentation/
│   ├── Screens/
│   │   ├── Home/
│   │   │   ├── HomeView.swift
│   │   │   └── HomeViewModel.swift
│   │   ├── Search/
│   │   │   ├── AddressSearchView.swift
│   │   │   └── AddressSearchViewModel.swift
│   │   ├── Results/
│   │   │   ├── RiskResultsView.swift
│   │   │   ├── RiskResultsViewModel.swift
│   │   │   └── Components/
│   │   │       ├── RiskCardView.swift
│   │   │       ├── RiskDetailSheet.swift
│   │   │       └── OverallRiskGauge.swift
│   │   ├── SavedAddresses/
│   │   └── Settings/
│   │
│   ├── Components/
│   │   ├── RiskLevelBadge.swift
│   │   ├── DataSourceRow.swift
│   │   └── QuestionsList.swift
│   │
│   └── Navigation/
│       └── NavigationRouter.swift
│
├── Domain/
│   ├── Entities/
│   │   ├── Address.swift
│   │   ├── RiskAssessment.swift
│   │   ├── RiskCategory.swift
│   │   └── RiskLevel.swift
│   │
│   └── UseCases/
│       ├── GetRiskAssessmentUseCase.swift
│       └── SaveAddressUseCase.swift
│
├── Data/
│   ├── Services/
│   │   ├── GeocodingService.swift
│   │   ├── FloodService.swift
│   │   ├── WildfireService.swift
│   │   ├── AirQualityService.swift
│   │   ├── EarthquakeService.swift
│   │   └── VolcanoService.swift
│   │
│   ├── Persistence/
│   │   ├── SwiftDataManager.swift
│   │   └── Models/
│   │       └── SavedAddressModel.swift
│   │
│   ├── BundledData/
│   │   ├── liquefaction.geojson
│   │   ├── lahar_zones.geojson
│   │   └── tsunami_zones.geojson
│   │
│   └── Network/
│       ├── APIClient.swift
│       └── NetworkError.swift
│
├── Core/
│   ├── Extensions/
│   ├── Utilities/
│   │   └── GeoJSONParser.swift
│   └── Theme/
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

### Key Swift Frameworks

| Framework | Purpose |
|-----------|---------|
| **SwiftUI** | Declarative UI |
| **SwiftData** | Local persistence |
| **MapKit** | Address autocomplete |
| **Observation** | @Observable view models (iOS 17+) |

### Dependencies (Swift Package Manager)

| Package | Purpose |
|---------|---------|
| None required | URLSession handles all networking |

---

## Data Models

### Domain Entities

```swift
// MARK: - Risk Level

enum RiskLevel: String, CaseIterable, Codable {
    case low, moderate, high, veryHigh

    var color: Color {
        switch self {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }
}

// MARK: - Risk Category

enum RiskCategory: String, CaseIterable, Identifiable, Codable {
    case flood, wildfire, airQuality, earthquake, volcano

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .flood: return "drop.fill"
        case .wildfire: return "flame.fill"
        case .airQuality: return "aqi.medium"
        case .earthquake: return "waveform.path.ecg"
        case .volcano: return "mountain.2.fill"
        }
    }

    var displayName: String {
        switch self {
        case .flood: return "Flood"
        case .wildfire: return "Wildfire"
        case .airQuality: return "Air Quality"
        case .earthquake: return "Earthquake"
        case .volcano: return "Volcano"
        }
    }
}

// MARK: - Risk Assessment

struct RiskAssessment: Identifiable {
    let id: UUID
    let address: Address
    let overallRisk: RiskLevel
    let risks: [RiskCategory: RiskDetail]
    let timestamp: Date
}

// MARK: - Risk Detail

struct RiskDetail: Identifiable, Codable {
    let id: UUID
    let category: RiskCategory
    let level: RiskLevel
    let summary: String
    let sources: [DataSource]
    let whatThisMeans: String
    let questionsToAsk: [String]
    let externalLinks: [ExternalLink]
}
```

---

## SwiftUI Views

### Risk Card Component

```swift
struct RiskCardView: View {
    let detail: RiskDetail
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Image(systemName: detail.category.icon)
                        .font(.title2)
                        .foregroundStyle(detail.level.color)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(detail.category.displayName)
                            .font(.headline)
                        Text(detail.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    RiskLevelBadge(level: detail.level)

                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                expandedContent
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Data Sources
            VStack(alignment: .leading, spacing: 8) {
                Text("Data Sources")
                    .font(.caption).fontWeight(.semibold)
                ForEach(detail.sources) { source in
                    DataSourceRow(source: source)
                }
            }

            // What This Means
            VStack(alignment: .leading, spacing: 8) {
                Text("What This Means")
                    .font(.caption).fontWeight(.semibold)
                Text(detail.whatThisMeans)
                    .font(.subheadline)
            }

            // Questions to Ask
            if !detail.questionsToAsk.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Questions to Ask")
                        .font(.caption).fontWeight(.semibold)
                    ForEach(detail.questionsToAsk, id: \.self) { q in
                        Text("• \(q)").font(.subheadline)
                    }
                }
            }
        }
        .padding()
    }
}
```

---

## App Store Pricing

| Product ID | Type | Price |
|------------|------|-------|
| App purchase | Paid app | $9.99 |

No in-app purchases or subscriptions required.

---

## Development Phases

### Phase 1: MVP (COMPLETE ✅)
- [x] Xcode project setup
- [x] API client and networking (URLSession)
- [x] Basic search → results flow
- [x] Flood, wildfire, air quality integration
- [x] Working PoC with real API data

### Phase 2: Full WA Data
- [ ] Add earthquake risk (bundle liquefaction GeoJSON)
- [ ] Add volcano risk (bundle lahar zone GeoJSON)
- [ ] MapKit address autocomplete
- [ ] Expandable risk cards with details

### Phase 3: Polish & Persistence
- [ ] SwiftData for saved addresses
- [ ] Offline caching of results
- [ ] Questions to Ask for each risk
- [ ] External links to official sources
- [ ] Move API key to Keychain

### Phase 4: Launch
- [ ] App Store assets (screenshots, description)
- [ ] TestFlight beta
- [ ] Analytics & crash reporting
- [ ] App Store submission

---

## App Store Info

**Category**: Reference or Lifestyle

**Keywords**: climate risk, home buying, flood risk, wildfire, earthquake, washington state, property risk, natural hazards

**Privacy**: Location (optional, for current location lookup). No account required. No data collected.

**Price**: $9.99 USD

---

## API Reference

### Live APIs (called directly from iOS app)

| API | Endpoint | Auth |
|-----|----------|------|
| Census Geocoding | `geocoding.geo.census.gov/geocoder/locations/onelineaddress` | None |
| FEMA NFHL | `hazards.fema.gov/arcgis/rest/services/public/NFHL/MapServer/28/query` | None |
| WA DNR WUI | `gis.dnr.wa.gov/site3/rest/services/Public_Wildfire/WADNR_PUBLIC_WD_WUI/MapServer/identify` | None |
| EPA AirNow | `www.airnowapi.org/aq/observation/latLong/current/` | Free API key |

### Bundled Data (GeoJSON in app bundle)

| Dataset | Source | Size | Update Frequency |
|---------|--------|------|------------------|
| Liquefaction zones | WA DNR | ~5MB | Rare (geological) |
| Lahar hazard zones | WA DNR/USGS | ~1MB | Rare |
| Tsunami zones | WA DNR | ~2MB | Rare |

---

## Next Steps

1. ~~Validate PoC with real APIs~~ ✅
2. Bundle GeoJSON data for earthquake/volcano
3. Implement MapKit autocomplete
4. Add expandable card details
5. Prepare App Store listing
