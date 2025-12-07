# ClimateHome

**Washington State Climate Risk Assessment Tool for Homebuyers**

An iOS app that helps homebuyers understand climate and natural hazard risks for properties in Washington State. Unlike tools that rely on single proprietary models, ClimateHome aggregates multiple government data sources and presents them with clear risk indicators.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Address Lookup** - Enter any Washington State address to get risk assessment
- **Multi-Source Data** - Aggregates flood, wildfire, and air quality data from official government APIs
- **Fast Response** - Parallel API calls deliver results in ~1 second
- **Clear Risk Levels** - Simple Low/Moderate/High indicators with detailed explanations
- **Data Transparency** - Shows source attribution for all risk data

## Risk Categories

| Category | Data Source | What It Shows |
|----------|-------------|---------------|
| 🌊 **Flood** | FEMA NFHL | Flood zone designation (X, AE, VE, etc.) |
| 🔥 **Wildfire** | WA DNR WUI | Wildland-Urban Interface classification |
| 💨 **Air Quality** | EPA AirNow | Current AQI and category |

## Screenshots

*Coming soon*

## Requirements

- iOS 17.0+
- Xcode 15.0+
- EPA AirNow API key (free at [airnowapi.org](https://docs.airnowapi.org/))

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/JoshuaOliphant/ClimateHome.git
   ```

2. Open `ClimateHome.xcodeproj` in Xcode

3. Add your EPA AirNow API key in `ContentView.swift`:
   ```swift
   @State private var viewModel = RiskLookupViewModel(airNowAPIKey: "YOUR_API_KEY")
   ```

4. Build and run on simulator or device

## Architecture

```
ClimateHome/
├── Models/           # Data models and API response types
├── Services/         # API client and service layer
├── ViewModels/       # Observable view models
└── Views/            # SwiftUI views
```

### Data Flow

1. User enters address
2. Census Geocoding API converts address to coordinates
3. Three risk APIs queried in parallel:
   - WA DNR WUI MapServer (identify endpoint for raster data)
   - FEMA NFHL MapServer (query endpoint for flood zones)
   - EPA AirNow API (current observations)
4. Results aggregated and displayed with risk levels

## API Documentation

### Census Geocoding
- **Endpoint**: `geocoding.geo.census.gov/geocoder/locations/onelineaddress`
- **Auth**: None required
- **Returns**: Coordinates and standardized address

### WA DNR Wildland-Urban Interface
- **Endpoint**: `gis.dnr.wa.gov/site3/rest/services/Public_Wildfire/WADNR_PUBLIC_WD_WUI/MapServer/identify`
- **Auth**: None required
- **Returns**: WUI classification (Interface, Intermix, or non-WUI)

### FEMA National Flood Hazard Layer
- **Endpoint**: `hazards.fema.gov/arcgis/rest/services/public/NFHL/MapServer/28/query`
- **Auth**: None required
- **Returns**: Flood zone designation and SFHA status

### EPA AirNow
- **Endpoint**: `www.airnowapi.org/aq/observation/latLong/current/`
- **Auth**: Free API key required
- **Returns**: Current AQI and pollutant levels

## Roadmap

- [ ] Add earthquake risk (WA DNR liquefaction data)
- [ ] Add volcano/lahar risk (Mt. Rainier hazard zones)
- [ ] Historical air quality trends
- [ ] Save and compare addresses
- [ ] Premium PDF reports

## Contributing

Contributions welcome! Please read the contributing guidelines before submitting PRs.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [FEMA](https://www.fema.gov/) for National Flood Hazard Layer data
- [WA DNR](https://www.dnr.wa.gov/) for Wildland-Urban Interface mapping
- [EPA](https://www.epa.gov/) for AirNow air quality data
- [U.S. Census Bureau](https://www.census.gov/) for geocoding services
