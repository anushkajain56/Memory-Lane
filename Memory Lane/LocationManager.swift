//
//  Memory_Manager.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/19/25.
//

import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var locationError: String?
    @Published var backgroundLocationEnabled = false
    @Published var backgroundUpdateCount = 0
    @Published var detectedMemoryLocations: [String] = []
    @Published var backgroundTriggerCandidates: [Memory] = []   // ✅ keep only this
    
    private var savedMemories: [Memory] = []
    
    // MARK: - Memory Handling
    func updateSavedMemories(_ memories: [Memory]) {
        savedMemories = memories
    }

    private func checkForNearbyMemories(at location: CLLocation) {
        let nearbyMemories = savedMemories.filter { memory in
            guard memory.hasValidLocation else { return false }
            
            let memoryLocation = CLLocation(latitude: memory.latitude, longitude: memory.longitude)
            let distance = location.distance(from: memoryLocation)
            
            return distance <= 100.0 // Within 100 meters
        }
        
        if !nearbyMemories.isEmpty {
            let memoryTitles = nearbyMemories.map { $0.title.isEmpty ? "Untitled Memory" : $0.title }
            let detectionMessage = "Near \(nearbyMemories.count) memory location(s): \(memoryTitles.joined(separator: ", "))"
            
            if !detectedMemoryLocations.contains(detectionMessage) {
                detectedMemoryLocations.append(detectionMessage)
                print("🏠 Background memory detection: \(detectionMessage)")
                
                if let mostRecentMemory = nearbyMemories.sorted(by: { $0.timestamp > $1.timestamp }).first {
                                notificationManager?.scheduleMemoryNotification(for: mostRecentMemory, at: location)
                                print("📱 Scheduled background notification for memory: \(mostRecentMemory.title.isEmpty ? "Untitled" : mostRecentMemory.title)")
                            }
            }
        }
    }
    
    private func checkBackgroundTriggerCandidates(at location: CLLocation) {
        // ✅ Only keep Memory matches (not raw CLLocation)
        let exactMatches = savedMemories.filter { memory in
            guard memory.hasValidLocation else { return false }
            let memoryLocation = CLLocation(latitude: memory.latitude, longitude: memory.longitude)
            let distance = location.distance(from: memoryLocation)
            return distance <= 20.0 // Exact match radius
        }
        
        if !exactMatches.isEmpty {
            backgroundTriggerCandidates = exactMatches
            print("🎯 Background trigger candidates found: \(exactMatches.count) memories")
        }
    }
    
    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Configure for background location updates
        locationManager.distanceFilter = 10.0  // Update every 10 meters
        locationManager.pausesLocationUpdatesAutomatically = false
                
        // Check if background location is available
        backgroundLocationEnabled = (UIApplication.shared.backgroundRefreshStatus == .available)
    }
    
    // MARK: - Permissions
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestBackgroundLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Background Updates
    func startBackgroundLocationUpdates() {
        guard authorizationStatus == .authorizedAlways else {
            locationError = "Background location permission not granted"
            return
        }
        
        guard UIApplication.shared.backgroundRefreshStatus == .available else {
            locationError = "Background app refresh is disabled"
            return
        }
        
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        print("✅ Started background location updates")
    }
    
    func stopBackgroundLocationUpdates() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        print("🛑 Stopped background location updates")
    }
    
    // MARK: - Current Location
    func getCurrentLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationError = "Location permission not granted"
            return
        }
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch authorizationStatus {
        case .authorizedAlways:
            print("✅ Background location authorized")
            if backgroundLocationEnabled {
                startBackgroundLocationUpdates()
            }
        case .authorizedWhenInUse:
            print("⚠️ Only foreground location authorized")
            locationManager.startUpdatingLocation()
        case .denied:
            print("❌ Location access denied")
            locationError = "Location access denied"
        case .restricted:
            print("🚫 Location access restricted")
            locationError = "Location access restricted"
        case .notDetermined:
            print("❓ Location permission not determined")
        @unknown default:
            print("🤷 Unknown location authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationError = nil
        
        // Track background location updates and check for nearby memories
        let appState = UIApplication.shared.applicationState
        if appState == .background {
            backgroundUpdateCount += 1
            print("📍 Background location update #\(backgroundUpdateCount): \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // Check for nearby memories in background
            checkForNearbyMemories(at: location)
            
            // Store background trigger candidates for when app becomes active
            checkBackgroundTriggerCandidates(at: location)
        } else {
            // Foreground updates - process triggers immediately
            print("📍 Foreground location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error.localizedDescription
        print("❌ Location error: \(error.localizedDescription)")
    }
    
    // MARK: - Utility
    var isLocationAuthorized: Bool {
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    func startLocationUpdates() {
        if isLocationAuthorized {
            getCurrentLocation()
        }
    }
    
    // Add to LocationManager class:
    var notificationManager: NotificationManager?

    func setNotificationManager(_ manager: NotificationManager) {
        notificationManager = manager
    }
    

   
}
