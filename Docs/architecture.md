# ClimateHome - Technical Architecture

> **Washington State Climate Risk App for Homebuyers**
> Native iOS • Swift/SwiftUI • Freemium

---

## Executive Summary

ClimateHome is a native iOS application that helps Washington State homebuyers understand climate and natural hazard risks for properties they're considering. Unlike existing tools that rely on single proprietary models, ClimateHome aggregates multiple government data sources and presents them in plain English with actionable next steps.

### Key Decisions

| Decision | Choice |
|----------|--------|
| **Geographic Scope** | Washington State (expand later) |
| **Business Model** | Freemium (5 free lookups/month, premium reports) |
| **Brand Name** | ClimateHome |
| **Platform** | Native iOS (Swift/SwiftUI) |
| **Minimum iOS Version** | iOS 17.0 |

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
│  │ SwiftUI Views │  │ Use Cases     │  │ Repositories  │       │
│  │ ViewModels    │  │ Entities      │  │ API Clients   │       │
│  │ Navigation    │  │ Risk Models   │  │ Local Storage │       │
│  └───────────────┘  └───────────────┘  └───────────────┘       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND API (FastAPI)                        │
├─────────────────────────────────────────────────────────────────┤
│  • Aggregates multiple data sources into single response        │
│  • Caches expensive spatial queries                             │
│  • Handles user authentication & subscription management        │
│  • Generates PDF reports                                        │
│  • Manages lookup quotas                                        │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  External APIs  │ │  PostGIS DB     │ │  Redis Cache    │
├─────────────────┤ ├─────────────────┤ ├─────────────────┤
│ • FEMA NFHL     │ │ • Liquefaction  │ │ • API responses │
│ • WA DNR WUI    │ │ • Lahar zones   │ │ • Geocoding     │
│ • EPA AirNow    │ │ • Tsunami zones │ │ • Rate limits   │
│ • Census Geocode│ │ • User data     │ └─────────────────┘
└─────────────────┘ └─────────────────┘
```

### Why Keep a Backend?

1. **Data aggregation** - Single API call returns all risk data
2. **Spatial queries** - PostGIS queries faster server-side
3. **Caching** - Repeated lookups don't hit external APIs
4. **API key security** - Keys stay on server, not in app bundle
5. **Data updates** - Update datasets without app release

---

## iOS App Architecture

### Project Structure

```
ClimateHome/
├── App/
│   ├── ClimateHomeApp.swift
│   └── Configuration/
│       ├── Environment.swift
│       └── APIConfiguration.swift
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
│   ├── UseCases/
│   │   ├── GetRiskAssessmentUseCase.swift
│   │   └── SaveAddressUseCase.swift
│   │
│   └── Repositories/
│       └── RiskRepositoryProtocol.swift
│
├── Data/
│   ├── Network/
│   │   ├── APIClient.swift
│   │   ├── Endpoints/
│   │   │   └── RiskEndpoint.swift
│   │   ├── DTOs/
│   │   │   └── RiskAssessmentDTO.swift
│   │   └── Mappers/
│   │       └── RiskAssessmentMapper.swift
│   │
│   ├── Persistence/
│   │   ├── SwiftDataManager.swift
│   │   └── Models/
│   │       └── SavedAddressModel.swift
│   │
│   └── Repositories/
│       └── RiskRepository.swift
│
├── Core/
│   ├── Extensions/
│   ├── Utilities/
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
| **StoreKit 2** | In-app purchases |
| **AuthenticationServices** | Sign in with Apple |
| **Observation** | @Observable view models (iOS 17+) |

### Dependencies (Swift Package Manager)

| Package | Purpose |
|---------|---------|
| **Alamofire** | Networking |
| **RevenueCat** | Subscription management |

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
        case .flood: return "🌊"
        case .wildfire: return "🔥"
        case .airQuality: return "💨"
        case .earthquake: return "🏔️"
        case .volcano: return "🌋"
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
    let remainingFreeLookups: Int?
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
                    Text(detail.category.icon)
                        .font(.title2)
                    
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

## ViewModel Layer

```swift
import Observation

@Observable
final class RiskResultsViewModel {
    enum State {
        case loading
        case loaded(RiskAssessment)
        case error(String)
    }
    
    private let address: Address
    private let riskRepository: RiskRepositoryProtocol
    
    var state: State = .loading
    
    init(address: Address, riskRepository: RiskRepositoryProtocol = RiskRepository()) {
        self.address = address
        self.riskRepository = riskRepository
    }
    
    @MainActor
    func loadRiskAssessment() async {
        state = .loading
        do {
            let assessment = try await riskRepository.getRiskAssessment(for: address)
            state = .loaded(assessment)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
```

---

## Network Layer

```swift
import Alamofire

final class APIClient {
    static let shared = APIClient()
    private let baseURL = URL(string: Environment.apiBaseURL)!
    
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)
        return try await AF.request(url, method: endpoint.method, parameters: endpoint.parameters)
            .validate()
            .serializingDecodable(T.self)
            .value
    }
}

enum RiskEndpoint: Endpoint {
    case getRisk(address: String)
    
    var path: String { "/api/risk" }
    var method: HTTPMethod { .get }
    var parameters: Parameters? {
        switch self {
        case .getRisk(let address): return ["address": address]
        }
    }
}
```

---

## Freemium Model (StoreKit 2)

| Product ID | Type | Price |
|------------|------|-------|
| `com.climatehome.report.single` | Consumable | $4.99 |
| `com.climatehome.pro.monthly` | Auto-renewable | $9.99/mo |
| `com.climatehome.pro.yearly` | Auto-renewable | $79.99/yr |

---

## Backend API Endpoints

```
GET  /api/risk?address={address}     Risk assessment
POST /api/report                     Generate PDF report
POST /api/auth/apple                 Sign in with Apple
GET  /api/user/lookups               Remaining lookups
POST /api/subscriptions/verify       Verify IAP receipt
```

---

## Development Phases

### Phase 1: MVP (3-4 weeks)
- [ ] Xcode project setup with SPM
- [ ] API client and networking
- [ ] Home → Search → Results flow
- [ ] MapKit address autocomplete
- [ ] Backend: flood + wildfire endpoints

### Phase 2: Full WA Data (2-3 weeks)
- [ ] All 5 risk categories
- [ ] PostGIS spatial data import
- [ ] SwiftData persistence
- [ ] Offline caching

### Phase 3: Monetization (2-3 weeks)
- [ ] Sign in with Apple
- [ ] StoreKit 2 / RevenueCat
- [ ] Report purchase flow
- [ ] Subscription management

### Phase 4: Launch (2 weeks)
- [ ] App Store assets
- [ ] TestFlight beta
- [ ] Analytics & crash reporting
- [ ] App Store submission

---

## App Store Info

**Category**: Lifestyle or Reference

**Keywords**: climate risk, home buying, flood risk, wildfire, earthquake, washington state, property risk

**Privacy**: Email, Location, Purchase History collected. No tracking.

---

## Next Steps

1. Create Xcode project with folder structure
2. Set up SPM dependencies
3. Build API client with mock data
4. Implement Home → Search → Results flow
