//
//  LocationStatusView.swift
//  Memory Lane
//
//  Created by Alex on 8/19/25.
//

import SwiftUI
import CoreLocation

struct LocationStatusView: View {
    @ObservedObject var locationManager: LocationManager
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private var statusColor: Color {
        if locationManager.currentLocation != nil {
            return .green
        } else if locationManager.authorizationStatus == .denied {
            return .red
        } else if locationManager.authorizationStatus == .notDetermined {
            return .yellow
        } else {
            return .gray
        }
    }
    
    private var statusMessage: String {
        if locationManager.currentLocation != nil {
            return "Location Active"
        } else if locationManager.authorizationStatus == .denied {
            return "Permission Denied"
        } else if locationManager.authorizationStatus == .notDetermined {
            return "Permission Needed"
        } else {
            return "Location Unavailable"
        }
    }
    
    private var backgroundLocationStatusColor: Color {
        if locationManager.authorizationStatus == .authorizedAlways && locationManager.backgroundLocationEnabled {
            return .green
        } else if locationManager.authorizationStatus == .authorizedWhenInUse {
            return .yellow
        } else {
            return .red
        }
    }
    
    private var backgroundLocationStatusMessage: String {
        if locationManager.authorizationStatus == .authorizedAlways {
            if locationManager.backgroundLocationEnabled {
                return "Background location active"
            } else {
                return "Background app refresh disabled"
            }
        } else if locationManager.authorizationStatus == .authorizedWhenInUse {
            return "Background location available"
        } else {
            return "Background location unavailable"
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Current Location")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            
            if let location = locationManager.currentLocation {
                VStack(spacing: 12) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Latitude:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(location.coordinate.latitude, specifier: "%.6f")")
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        HStack {
                            Text("Longitude:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(location.coordinate.longitude, specifier: "%.6f")")
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    
                    Divider()
                    
                    VStack(spacing: 5) {
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundColor(.blue)
                            Text("Accuracy: ±\(Int(location.horizontalAccuracy)) meters")
                                .font(.caption)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            Text("Updated: \(location.timestamp, formatter: timeFormatter)")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            } else {
                Text("Location not available")
                    .foregroundColor(.gray)
                    .italic()
            }
            
            // Background location status indicator
            HStack {
                Circle()
                    .fill(backgroundLocationStatusColor)
                    .frame(width: 8, height: 8)
                Text(backgroundLocationStatusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

#Preview {
    LocationStatusView(locationManager: LocationManager())
}