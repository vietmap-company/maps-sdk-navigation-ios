import Foundation
import VietMapDirections
import VietMapPolyline

class CoreFeedbackEvent: Hashable {
    var id = UUID()
    
    var timestamp: Date
    
    var eventDictionary: [String: Any]
    
    init(timestamp: Date, eventDictionary: [String: Any]) {
        self.timestamp = timestamp
        self.eventDictionary = eventDictionary
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: CoreFeedbackEvent, rhs: CoreFeedbackEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

class FeedbackEvent: CoreFeedbackEvent {
    func update(type: FeedbackType, source: FeedbackSource, description: String?) {
        eventDictionary["feedbackType"] = type.description
        eventDictionary["source"] = source.description
        eventDictionary["description"] = description
    }
}

class RerouteEvent: CoreFeedbackEvent {
    func update(newRoute: Route) {
        if let geometry = newRoute.coordinates {
            eventDictionary["newGeometry"] = Polyline(coordinates: geometry).encodedPolyline
            eventDictionary["newDistanceRemaining"] = round(newRoute.distance)
            eventDictionary["newDurationRemaining"] = round(newRoute.expectedTravelTime)
        }
    }
}
