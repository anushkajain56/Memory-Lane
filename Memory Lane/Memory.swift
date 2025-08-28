//
//  File.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/19/25.
//

import Foundation
import SwiftUI
import CoreLocation


struct Memory: Identifiable, Codable {
    let id = UUID()
    var photoData: Data?
    var title: String
    var content: String
    var latitude: Double
    var longitude: Double
    var timestamp: Date
    var accuracy: Double
    var locationCaptured: Bool
    
    init(photo: UIImage? = nil, title: String = "", content: String = "", location: CLLocation? = nil) {
        if let photo = photo {
            self.photoData = photo.jpegData(compressionQuality: 0.8)
        } else {
            self.photoData = nil
        }
        self.title = title
        self.content = content
        
        if let location = location {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.accuracy = location.horizontalAccuracy
            self.locationCaptured = true
        } else {
            self.latitude = 0.0
            self.longitude = 0.0
            self.accuracy = 0.0
            self.locationCaptured = false
        }
        
        self.timestamp = Date()
    }
    
    var photo: UIImage? {
        guard let photoData = photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    var hasValidLocation: Bool {
        return locationCaptured && accuracy > 0 && (latitude != 0.0 || longitude != 0.0)
    }
}
