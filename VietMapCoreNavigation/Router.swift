import Foundation
import CoreLocation
import VietMapDirections

@objc public protocol Router: AnyObject, CLLocationManagerDelegate {
    @objc var locationManager: NavigationLocationManager! { get }
    
    var usesDefaultUserInterface: Bool { get }
    var routeProgress: RouteProgress { get }
    func endNavigation()

    @objc var location: CLLocation? { get }
}
