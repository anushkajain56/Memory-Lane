//
//  ActionButtonsView.swift
//  Memory Lane
//
//  Created by Alex on 8/19/25.
//

import SwiftUI

struct ActionButtonsView: View {
    @ObservedObject var locationManager: LocationManager
    let memories: [Memory]
    let canSaveMemory: Bool
    let onSaveMemory: () -> Void
    let onClearMemories: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Refresh Location Button
            Button(action: {
                locationManager.getCurrentLocation()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh Location")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(locationManager.isLocationAuthorized ? .blue : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(locationManager.isLocationAuthorized ? Color.blue : Color.gray, lineWidth: 1)
                )
            }
            .disabled(!locationManager.isLocationAuthorized)
            .padding(.horizontal)
            
            // Enable Background Location Button
            if locationManager.authorizationStatus == .authorizedWhenInUse {
                VStack(spacing: 8) {
                    Button(action: {
                        locationManager.requestBackgroundLocationPermission()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Enable Background Location")
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    
                    Text("Background location allows MemoryLane to notify you when you return to places with memories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            // Background Location Test Buttons
            if locationManager.authorizationStatus == .authorizedAlways {
                HStack(spacing: 15) {
                    Button(action: {
                        testBackgroundLocation()
                    }) {
                        HStack {
                            Image(systemName: "testtube.2")
                            Text("Test")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        toggleBackgroundLocationUpdates()
                    }) {
                        HStack {
                            Image(systemName: "location.fill.viewfinder")
                            Text("Start Updates")
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // Save Memory Button
            if canSaveMemory {
                Button(action: onSaveMemory) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Memory")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            
            // Clear All Memories Button
            if !memories.isEmpty {
                Button(action: onClearMemories) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All Memories")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
                }
                .padding(.top, 10)
            }
        }
    }
    
    private func testBackgroundLocation() {
        guard locationManager.authorizationStatus == .authorizedAlways else {
            print("❌ Cannot test background location: Permission not granted")
            return
        }
        
        print("🧪 Testing background location functionality...")
        print("   - Authorization: \(locationManager.authorizationStatus.rawValue)")
        print("   - Background location enabled: \(locationManager.backgroundLocationEnabled)")
        
        locationManager.startBackgroundLocationUpdates()
        
        // Schedule a test to check if updates are working
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if let location = locationManager.currentLocation {
                print("✅ Background location test successful - Last update: \(location.timestamp)")
            } else {
                print("⚠️ Background location test inconclusive - No recent updates")
            }
        }
    }

    private func toggleBackgroundLocationUpdates() {
        if locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startBackgroundLocationUpdates()
        }
    }
}


