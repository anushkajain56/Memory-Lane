//
//  Extensions.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/19/25.
//

import Foundation
import CoreLocation

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Asked Yet"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        case .authorizedWhenInUse:
            return "Authorized"
        case .authorizedAlways:
            return "Always Authorized"
        @unknown default:
            return "Unknown"
        }
    }
}

extension Memory {
    var locationString: String {
        guard hasValidLocation else { return "No location" }
        return String(format: "%.4f, %.4f", latitude, longitude)
    }
    
    var preciseLocationString: String {
        guard hasValidLocation else { return "No location" }
        return String(format: "%.6f, %.6f", latitude, longitude)
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var accuracyDescription: String {
        guard hasValidLocation else { return "No location data" }
        if accuracy < 5 {
            return "Very accurate (±\(Int(accuracy))m)"
        } else if accuracy < 20 {
            return "Accurate (±\(Int(accuracy))m)"
        } else {
            return "Approximate (±\(Int(accuracy))m)"
        }
    }
    
    var hasPhoto: Bool {
        return photo != nil
    }
    
    var hasNotes: Bool {
        return !content.isEmpty || !title.isEmpty
    }
    
    var isComplete: Bool {
        return hasValidLocation && (hasPhoto || hasNotes)
    }
    
    func distanceTo(_ otherMemory: Memory) -> Double? {
        guard hasValidLocation && otherMemory.hasValidLocation else { return nil }
        
        let thisLocation = CLLocation(latitude: latitude, longitude: longitude)
        let otherLocation = CLLocation(latitude: otherMemory.latitude, longitude: otherMemory.longitude)
        
        return thisLocation.distance(from: otherLocation)
    }
    
    func distanceString(to otherMemory: Memory) -> String {
        guard let distance = distanceTo(otherMemory) else { return "Distance unknown" }
        
        if distance < 1000 {
            return "\(Int(distance)) meters away"
        } else {
            return "\(String(format: "%.1f", distance / 1000)) km away"
        }
    }
}
