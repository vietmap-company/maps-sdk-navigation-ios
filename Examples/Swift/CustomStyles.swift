import Foundation
import VietMapNavigation

/**
 To find more pieces of the UI to customize, checkout DayStyle.swift.
 */
// MARK: CustomDayStyle
class CustomDayStyle: DayStyle {
    
//    required init() {
//        super.init()
//        mapStyleURL = URL(string: "mapbox://styles/mapbox/satellite-streets-v9")!
//        styleType = .day
//    }
    
    required init(mapStyleURL: URL) {
        super.init(mapStyleURL: mapStyleURL)
        self.mapStyleURL = mapStyleURL
        styleType = .day
    }
    
    override func apply() {
        super.apply()
        BottomBannerView.appearance().backgroundColor = .orange
    }
}

// MARK: CustomNightStyle
class CustomNightStyle: NightStyle {
    
//    required init() {
//        super.init()
//        mapStyleURL = URL(string: "mapbox://styles/mapbox/satellite-streets-v9")!
//        styleType = .night
//    }
    
    required init(mapStyleURL: URL) {
        super.init(mapStyleURL: mapStyleURL)
        self.mapStyleURL = mapStyleURL
        styleType = .night
    }
    
    override func apply() {
        super.apply()
        BottomBannerView.appearance().backgroundColor = .purple
    }
}
