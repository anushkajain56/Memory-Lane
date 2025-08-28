//
//  LocationMatching.swift
//  Memory Lane
//
//  Created by Alex on 8/19/25.
//

import Foundation
import CoreLocation

struct LocationMatching {
    static let exactMatchRadius: Double = 25.0      // Within 25 meters - same location
    static let nearbyRadius: Double = 100.0         // Within 100 meters - nearby
    static let broadRadius: Double = 500.0          // Within 500 meters - same area
    static let minimumAccuracy: Double = 100.0      // Minimum GPS accuracy for matching
    static let highAccuracyThreshold: Double = 20.0 // High accuracy threshold for GPS
}

enum LocationMatchType: CaseIterable {
    case exact
    case nearby
    case area
    case distant
    
    var description: String {
        switch self {
        case .exact: return "Same location"
        case .nearby: return "Nearby"
        case .area: return "Same area"
        case .distant: return "Distant"
        }
    }
    
    var radius: Double {
        switch self {
        case .exact: return LocationMatching.exactMatchRadius
        case .nearby: return LocationMatching.nearbyRadius
        case .area: return LocationMatching.broadRadius
        case .distant: return Double.infinity
        }
    }
}

class LocationMatchingService {
    
    static func distanceBetween(current: CLLocation, memory: Memory) -> Double? {
        guard memory.hasValidLocation else { return nil }
        
        let memoryLocation = CLLocation(latitude: memory.latitude, longitude: memory.longitude)
        return current.distance(from: memoryLocation)
    }
    
    static func isLocationMatch(current: CLLocation, memory: Memory, radius: Double = LocationMatching.exactMatchRadius) -> Bool {
        guard let distance = distanceBetween(current: current, memory: memory) else { return false }
        guard current.horizontalAccuracy <= LocationMatching.minimumAccuracy else { return false }
        guard memory.accuracy <= LocationMatching.minimumAccuracy else { return false }
        
        return distance <= radius
    }
    
    static func getMemoriesNear(location: CLLocation, memories: [Memory], radius: Double) -> [Memory] {
        return memories.filter { memory in
            isLocationMatch(current: location, memory: memory, radius: radius)
        }.sorted { memory1, memory2 in
            let distance1 = distanceBetween(current: location, memory: memory1) ?? Double.infinity
            let distance2 = distanceBetween(current: location, memory: memory2) ?? Double.infinity
            return distance1 < distance2
        }
    }
    
    static func getLocationMatchType(current: CLLocation, memory: Memory) -> LocationMatchType? {
        guard let distance = distanceBetween(current: current, memory: memory) else { return nil }
        
        guard current.horizontalAccuracy <= LocationMatching.minimumAccuracy else { return nil }
        guard memory.accuracy <= LocationMatching.minimumAccuracy else { return nil }
        
        if distance <= LocationMatching.exactMatchRadius {
            return .exact
        } else if distance <= LocationMatching.nearbyRadius {
            return .nearby
        } else if distance <= LocationMatching.broadRadius {
            return .area
        } else {
            return .distant
        }
    }
    
    static func getMemoryClusters(from memories: [Memory]) -> [(location: String, count: Int)] {
        var clusters: [String: Int] = [:]
        
        for memory in memories where memory.hasValidLocation {
            // Round coordinates to create clusters (roughly 100m accuracy)
            let roundedLat = round(memory.latitude * 1000) / 1000  // ~111m precision
            let roundedLng = round(memory.longitude * 1000) / 1000
            let clusterKey = "\(roundedLat),\(roundedLng)"
            
            clusters[clusterKey] = (clusters[clusterKey] ?? 0) + 1
        }
        
        return clusters.map { (location: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }
}