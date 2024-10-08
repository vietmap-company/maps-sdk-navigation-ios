import UIKit
import VietMapCoreNavigation
import VietMapNavigation
import VietMapDirections
import UserNotifications


private typealias RouteRequestSuccess = (([Route]) -> Void)
private typealias RouteRequestFailure = ((NSError) -> Void)


class ViewController: UIViewController, MLNMapViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var longPressHintView: UIView!
    @IBOutlet weak var simulationButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var clearMap: UIButton!
    @IBOutlet weak var bottomBarBackground: UIView!
      
    let navigationViewController = NavigationViewController(dayStyle:  DayStyle(mapStyleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE")!))
    // MARK: Properties
    var mapView: NavigationMapView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let mapView = mapView {
                configureMapView(mapView)
                view.insertSubview(mapView, belowSubview: longPressHintView)
            }
        }
    }
    
    var waypoints: [Waypoint] = [] {
        didSet {
            waypoints.forEach {
                $0.coordinateAccuracy = -1
            }
        }
    }

    var routes: [Route]? {
        didSet {
            startButton.isEnabled = (routes?.count ?? 0 > 0)
            guard let routes = routes,
                  let current = routes.first else { mapView?.removeRoutes(); return }

            mapView?.showRoutes(routes)
            mapView?.showWaypoints(current)
        }
    }

    // MARK: Directions Request Handlers
    
    @objc public var overheadInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 70, right: 20)
    }

    fileprivate lazy var defaultSuccess: RouteRequestSuccess = { [weak self] (routes) in
        guard let current = routes.first else { return }
        self?.mapView?.removeWaypoints()
        self?.routes = routes
        self?.waypoints = current.routeOptions.waypoints
        self?.clearMap.isHidden = false
        self?.longPressHintView.isHidden = true
        self?.mapView?.setOverheadCameraView(from: (self?.waypoints.first!.coordinate)!, along: current.coordinates!, for: self!.overheadInsets)
    }

    fileprivate lazy var defaultFailure: RouteRequestFailure = { [weak self] (error) in
        self?.routes = nil //clear routes from the map
        print(error.localizedDescription)
    }

    var alertController: UIAlertController!
    
    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertController = UIAlertController(title: "Start Navigation", message: "Select the navigation type", preferredStyle: .actionSheet)
        
        typealias ActionHandler = (UIAlertAction) -> Void
        simulationButton.isSelected = false
        let basic: ActionHandler = {_ in self.startBasicNavigation() }
        let day: ActionHandler = {_ in self.startNavigation(styles: [DayStyle()]) }
        let night: ActionHandler = {_ in self.startNavigation(styles: [NightStyle()]) }
        let custom: ActionHandler = {_ in self.startCustomNavigation() }
        let styled: ActionHandler = {_ in self.startStyledNavigation() }
        
        let actionPayloads: [(String, UIAlertAction.Style, ActionHandler?)] = [
            ("Default UI", .default, basic),
            ("DayStyle UI", .default, day),
            ("NightStyle UI", .default, night),
            ("Custom UI", .default, custom),
            ("Styled UI", .default, styled),
            ("Cancel", .cancel, nil)
        ]
        
        actionPayloads
            .map { payload in UIAlertAction(title: payload.0, style: payload.1, handler: payload.2)}
            .forEach(alertController.addAction(_:))

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.startButton
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.mapView = NavigationMapView(frame: view.bounds, styleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE"))

        // Reset the navigation styling to the defaults if we are returning from a presentation.
        if (presentedViewController != nil) {
            DayStyle().apply()
        }
        Locale.localeVoice = "vi"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _,_ in
                DispatchQueue.main.async {
                    CLLocationManager().requestWhenInUseAuthorization()
                }
            }
        }
    }

    // MARK: Gesture Recognizer Handlers

    @objc func didLongPress(tap: UILongPressGestureRecognizer) {
        guard let mapView = mapView, tap.state == .began else { return }

        if let annotation = mapView.annotations?.last, waypoints.count > 2 {
            mapView.removeAnnotation(annotation)
        }

        if waypoints.count > 1 {
            waypoints = Array(waypoints.suffix(1))
        }
        
        let coordinates = mapView.convert(tap.location(in: mapView), toCoordinateFrom: mapView)
        // Note: The destination name can be modified. The value is used in the top banner when arriving at a destination.
        let waypoint = Waypoint(coordinate: coordinates, name: "Dropped Pin #\(waypoints.endIndex + 1)")
        waypoints.append(waypoint)

        requestRoute()
    }


    // MARK: - IBActions
    @IBAction func replay(_ sender: Any) {
        let bundle = Bundle(for: ViewController.self)
        let filePath = bundle.path(forResource: "tunnel", ofType: "json")!
        let routeFilePath = bundle.path(forResource: "tunnel", ofType: "route")!
        let route = NSKeyedUnarchiver.unarchiveObject(withFile: routeFilePath) as! Route

        let locationManager = ReplayLocationManager(locations: Array<CLLocation>.locations(from: filePath))

//        let navigationViewController = NavigationViewController(for: route, locationManager: locationManager)

        let dayStyle = DayStyle(mapStyleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE")!)
        let navigationViewController = NavigationViewController(dayStyle: dayStyle)
        navigationViewController.route = route
//        let directions = routeController.directions
//        let navigationViewController = NavigationViewController(dayStyle: DayStyle(demoStyle: ()), nightStyle: NightStyle(demoStyle: ()), directions: directions)
        present(navigationViewController, animated: true, completion: nil)
    }

    @IBAction func simulateButtonPressed(_ sender: Any) {
        simulationButton.isSelected = !simulationButton.isSelected
    }

    @IBAction func clearMapPressed(_ sender: Any) {
        clearMap.isHidden = true
        mapView?.removeRoutes()
        mapView?.removeWaypoints()
        waypoints.removeAll()
        longPressHintView.isHidden = false
        mapView?.recenterMap()
    }

    @IBAction func startButtonPressed(_ sender: Any) {
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Public Methods
    // MARK: Route Requests
    func requestRoute() {
        guard waypoints.count > 0 else { return }
        guard let mapView = mapView else { return }

        let userWaypoint = Waypoint(location: mapView.userLocation!.location!, heading: mapView.userLocation?.heading, name: "User location")
        waypoints.insert(userWaypoint, at: 0)

        let options = NavigationRouteOptions(waypoints: waypoints)
        options.shapeFormat = .polyline6

        requestRoute(with: options, success: defaultSuccess, failure: defaultFailure)
    }

    fileprivate func requestRoute(with options: RouteOptions, success: @escaping RouteRequestSuccess, failure: RouteRequestFailure?) {

        let handler: Directions.RouteCompletionHandler = {(waypoints, potentialRoutes, potentialError) in
            if let error = potentialError, let fail = failure { return fail(error) }
            guard let routes = potentialRoutes else { return }
            return success(routes)
        }

        _ = Directions.shared.calculate(options, completionHandler: handler)
    }

    // MARK: Basic Navigation

    func startBasicNavigation() {
        guard let route = routes?.first else { return }

//        let navigationViewController = NavigationViewController(for: route, locationManager: navigationLocationManager())
        let dayStyle = DayStyle(mapStyleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE")!)
        let navigationViewController = NavigationViewController(dayStyle: dayStyle)
        navigationViewController.route = route
        navigationViewController.delegate = self
        
        presentAndRemoveMapview(navigationViewController)
    }
    
    func startNavigation(styles: [Style]) {
        guard let route = routes?.first else { return }
        
//        let navigationViewController = NavigationViewController(for: route, styles: styles, locationManager: navigationLocationManager())
        
        let dayStyle = DayStyle(mapStyleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE")!)
        let navigationViewController = NavigationViewController(dayStyle: dayStyle)
        navigationViewController.route = route
        navigationViewController.delegate = self
        
        presentAndRemoveMapview(navigationViewController)
    }
    
    // MARK: Custom Navigation UI
    func startCustomNavigation() {
        guard let route = routes?.first else { return }

        guard let customViewController = storyboard?.instantiateViewController(withIdentifier: "custom") as? CustomViewController else { return }

        customViewController.userRoute = route

        let destination = MLNPointAnnotation()
        destination.coordinate = route.coordinates!.last!
        customViewController.destination = destination
        customViewController.simulateLocation = simulationButton.isSelected

        present(customViewController, animated: true, completion: nil)
    }

    // MARK: Styling the default UI

    func startStyledNavigation() {
        guard let route = routes?.first else { return }

        let styles = [CustomDayStyle(), CustomNightStyle()]

//        self.navigationViewController = NavigationViewController(for: route, styles: styles, locationManager: navigationLocationManager())
        
        let dayStyle = DayStyle(mapStyleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE")!)
        let navigationViewController = NavigationViewController(dayStyle: dayStyle)
        navigationViewController.route = route
        navigationViewController.delegate = self
        navigationViewController.mapView.showsUserHeadingIndicator = true
        navigationViewController.mapView.userTrackingMode = .follow
        presentAndRemoveMapview(navigationViewController)
    }

    func navigationLocationManager() -> NavigationLocationManager {
        guard let route = routes?.first else { return NavigationLocationManager() }
        let simulator = SimulatedLocationManager(route: route)
        simulator.speedMultiplier = 1
        return simulationButton.isSelected ? simulator : NavigationLocationManager()
    }

    func presentAndRemoveMapview(_ navigationViewController: NavigationViewController) {
        self.navigationViewController.mapView.styleURL = URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE");
        self.navigationViewController.mapView.tracksUserCourse = true
        NotificationCenter.default.addObserver(self, selector: #selector(progressDidChange(_ :)), name: .routeControllerProgressDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(progressDidReroute(_ :)), name: .routeControllerDidReroute, object: nil)
        present(navigationViewController, animated: true) {
            self.mapView?.removeFromSuperview()
            self.mapView = nil
        }
    }
    
    @objc func progressDidReroute(_ notification: Notification) {
        let location = notification.userInfo![RouteControllerNotificationUserInfoKey.locationKey] as! CLLocation
        if let userInfo = notification.object as? RouteController {
//            navigationViewController.mapView?.showRoutes([userInfo.routeProgress.route])
////            centerMap(userInfo.locationManager.location!)
//            navigationViewController.mapView?.recenterMap()
//            navigationViewController.mapView?.updateCourseTracking(location: location, animated: true)
        }
   }
    
    @objc func progressDidChange(_ notification: NSNotification ) {
//        let routeProgress = notification.userInfo![RouteControllerNotificationUserInfoKey.routeProgressKey] as! RouteProgress
        let location = notification.userInfo![RouteControllerNotificationUserInfoKey.locationKey] as! CLLocation
        print("---------start get location-------------")
        print(location.coordinate)
        print("---------end   get location-------------")
//        if ((navigationViewController.mapView?.tracksUserCourse) != nil && (navigationViewController.mapView?.tracksUserCourse) == true) {
//            let camera = MLNMapCamera(
//                lookingAtCenter: location.coordinate,
//                acrossDistance: 500,
//                pitch: 75,
//                heading: location.course
//            )
//            print("locaiton: \(location.coordinate)")
//            navigationViewController.mapView?.setCamera(camera, animated: true)
//        }
//        navigationViewController.mapView?.updateCourseTracking(location: location, animated: true)
    }

    func configureMapView(_ mapView: NavigationMapView) {
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.navigationMapDelegate = self
        mapView.userTrackingMode = .followWithHeading

        let singleTap = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(tap:)))
        mapView.gestureRecognizers?.filter({ $0 is UILongPressGestureRecognizer }).forEach(singleTap.require(toFail:))
        mapView.addGestureRecognizer(singleTap)
    }

    func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
        self.mapView?.localizeLabels()
        
        if let routes = routes, let currentRoute = routes.first, let coords = currentRoute.coordinates {
            mapView.setVisibleCoordinateBounds(MLNPolygon(coordinates: coords, count: currentRoute.coordinateCount).overlayBounds, animated: false)
            self.mapView?.showRoutes(routes)
            self.mapView?.showWaypoints(currentRoute)
        }
    }
}

// MARK: - NavigationMapViewDelegate
extension ViewController: NavigationMapViewDelegate {
    func navigationMapView(_ mapView: NavigationMapView, didSelect waypoint: Waypoint) {
        guard let routeOptions = routes?.first?.routeOptions else { return }
        let modifiedOptions = routeOptions.without(waypoint: waypoint)

        presentWaypointRemovalActionSheet { _ in
            self.requestRoute(with:modifiedOptions, success: self.defaultSuccess, failure: self.defaultFailure)
        }
    }

    func navigationMapView(_ mapView: NavigationMapView, didSelect route: Route) {
        guard let routes = routes else { return }
        guard let index = routes.firstIndex(where: { $0 == route }) else { return }
        self.routes!.remove(at: index)
        self.routes!.insert(route, at: 0)
    }

    private func presentWaypointRemovalActionSheet(completionHandler approve: @escaping ((UIAlertAction) -> Void)) {
        let title = NSLocalizedString("Remove Waypoint?", comment: "Waypoint Removal Action Sheet Title")
        let message = NSLocalizedString("Would you like to remove this waypoint?", comment: "Waypoint Removal Action Sheet Message")
        let removeTitle = NSLocalizedString("Remove Waypoint", comment: "Waypoint Removal Action Item Title")
        let cancelTitle = NSLocalizedString("Cancel", comment: "Waypoint Removal Action Sheet Cancel Item Title")

        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let remove = UIAlertAction(title: removeTitle, style: .destructive, handler: approve)
        let cancel = UIAlertAction(title: cancelTitle, style: .cancel, handler: nil)
        [remove, cancel].forEach(actionSheet.addAction(_:))

        self.present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: VoiceControllerDelegate methods
// To use these delegate methods, set the `VoiceControllerDelegate` on your `VoiceController`.
extension ViewController: VoiceControllerDelegate {
    // Called when there is an error with speaking a voice instruction.
    func voiceController(_ voiceController: RouteVoiceController, spokenInstructionsDidFailWith error: Error) {
        print(error.localizedDescription)
    }
    // Called when an instruction is interrupted by a new voice instruction.
    func voiceController(_ voiceController: RouteVoiceController, didInterrupt interruptedInstruction: SpokenInstruction, with interruptingInstruction: SpokenInstruction) {
        print(interruptedInstruction.text, interruptingInstruction.text)
    }
    
    func voiceController(_ voiceController: RouteVoiceController, willSpeak instruction: SpokenInstruction, routeProgress: RouteProgress) -> SpokenInstruction? {
        return SpokenInstruction(distanceAlongStep: instruction.distanceAlongStep, text: "New Instruction!", ssmlText: "<speak>New Instruction!</speak>")
    }
    
    // By default, the routeController will attempt to filter out bad locations.
    // If however you would like to filter these locations in,
    // you can conditionally return a Bool here according to your own heuristics.
    // See CLLocation.swift `isQualified` for what makes a location update unqualified.
    func navigationViewController(_ navigationViewController: NavigationViewController, shouldDiscard location: CLLocation) -> Bool {
        return true
    }
}

// MARK: WaypointConfirmationViewControllerDelegate
extension ViewController: WaypointConfirmationViewControllerDelegate {
    func confirmationControllerDidConfirm(_ confirmationController: WaypointConfirmationViewController) {
//        confirmationController.dismiss(animated: true, completion: {
//            guard let navigationViewController = self.presentedViewController as? NavigationViewController else { return }
//
//            guard navigationViewController.routeController.routeProgress.route.legs.count > navigationViewController.routeController.routeProgress.legIndex + 1 else { return }
//            navigationViewController.routeController.routeProgress.legIndex += 1
//            navigationViewController.routeController.resume()
//        })
    }
}

// MARK: NavigationViewControllerDelegate
extension ViewController: NavigationViewControllerDelegate {
    // By default, when the user arrives at a waypoint, the next leg starts immediately.
    // If you implement this method, return true to preserve this behavior.
    // Return false to remain on the current leg, for example to allow the user to provide input.
    // If you return false, you must manually advance to the next leg. See the example above in `confirmationControllerDidConfirm(_:)`.
    func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) -> Bool {
        // When the user arrives, present a view controller that prompts the user to continue to their next destination
        // This type of screen could show information about a destination, pickup/dropoff confirmation, instructions upon arrival, etc.
        
        //If we're not in a "Multiple Stops" demo, show the normal EORVC
        if ((navigationViewController.routeController?.routeProgress.isFinalLeg) != nil) {
            return true
        }
        
        guard let confirmationController = self.storyboard?.instantiateViewController(withIdentifier: "waypointConfirmation") as? WaypointConfirmationViewController else {
            return true
        }

        confirmationController.delegate = self
        self.mapView = NavigationMapView(frame: view.bounds, styleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE"))
        navigationViewController.present(confirmationController, animated: true, completion: nil)
        return false
    }
    
    // Called when the user hits the exit button.
    // If implemented, you are responsible for also dismissing the UI.
    func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        self.mapView = NavigationMapView(frame: view.bounds, styleURL: URL(string: "https://maps.vietmap.vn/api/maps/light/styles.json?apikey=YOUR_API_KEY_HERE"))
        navigationViewController.dismiss(animated: true, completion: nil)
    }
}


// Mark: VisualInstructionDelegate
extension ViewController: VisualInstructionDelegate {
    func label(_ label: InstructionLabel, willPresent instruction: VisualInstruction, as presented: NSAttributedString) -> NSAttributedString? {
        
        // Uncomment to mutate the instruction shown in the top instruction banner
        // let range = NSRange(location: 0, length: presented.length)
        // let mutable = NSMutableAttributedString(attributedString: presented)
        // mutable.mutableString.applyTransform(.latinToKatakana, reverse: false, range: range, updatedRange: nil)
        // return mutable
        
        return presented
    }
}
