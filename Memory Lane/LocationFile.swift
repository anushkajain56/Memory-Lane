//
//  LocationFile.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/22/25.
//

import SwiftUI
import CoreLocation

struct LocationAccuracyWarningView: View {
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 8) {
            if let location = locationManager.currentLocation {
                if location.horizontalAccuracy > 50 {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                        Text("Location accuracy is low (±\(Int(location.horizontalAccuracy))m). Memory location may be imprecise.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            } else if locationManager.authorizationStatus == .authorizedWhenInUse {
                HStack {
                    Image(systemName: "location.slash")
                        .foregroundColor(.red)
                    Text("No location data available. Memories cannot be linked to locations.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}
