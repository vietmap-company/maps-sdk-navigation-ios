#if canImport(CarPlay)
import CarPlay
#endif

public enum FavoritesList {
    
    enum POI: RawRepresentable {
        typealias RawValue = String
        case mapboxSF, timesSquare
        static let all: [POI] = [.mapboxSF, .timesSquare]
        
        var subTitle: String {
            switch self {
            case .mapboxSF:
                return "Office Location"
            case .timesSquare:
                return "Downtown Attractions"
            }
        }
        
        var location: CLLocation {
            switch self {
            case .mapboxSF:
                return CLLocation(latitude: 10.766129, longitude: 106.657740)
            case .timesSquare:
                return CLLocation(latitude: 10.774137, longitude: 106.722039)
            }
        }
        
        var rawValue: String {
            switch self {
            case .mapboxSF:
                return "NTD Phu Tho"
            case .timesSquare:
                return "CV Sala"
            }
        }
        
        init?(rawValue: String) {
            let value = rawValue.lowercased()
            switch value {
            case "mapbox sf":
                self = .mapboxSF
            case "times square":
                self = .timesSquare
            default:
                return nil
            }
        }
        
        #if canImport(CarPlay)
        @available(iOS 12.0, *)
        func listItem() -> CPListItem {
            return CPListItem(text: rawValue, detailText: subTitle, image: nil, showsDisclosureIndicator: true)
        }
        #endif
    }
}
