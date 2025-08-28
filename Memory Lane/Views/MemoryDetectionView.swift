////
////  MemoryDetectionView.swift
////  Memory Lane
////
////  Created by Alex on 8/19/25.
////
//
//import SwiftUI
//import CoreLocation
//
//struct MemoryDetectionView: View {
//    let memories: [Memory]
//    @ObservedObject var locationManager: LocationManager
//
//    // MARK: - Exact location match
//    var exactLocationMemories: [Memory] {
//        memories.filter { memory in
//            guard let memoryLocation = memory.location,
//                  let currentLocation = locationManager.currentLocation else {
//                return false
//            }
//
//            let distance = currentLocation.distance(from: memoryLocation)
//            return distance < 50 // within 50 meters
//        }
//    }
//
//    // MARK: - View Body
//    var body: some View {
//        VStack {
//            if exactLocationMemories.isEmpty {
//                Text("No memories nearby")
//                    .foregroundColor(.secondary)
//                    .padding()
//            } else {
//                List(exactLocationMemories) { memory in
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(memory.title)
//                            .font(.headline)
//                        if let date = memory.date {
//                            Text(date.formatted())
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                    .padding(.vertical, 4)
//                }
//            }
//        }
//        .onAppear {
//            // Start updating location when view appears
//            locationManager.startUpdatingLocation()
//        }
//        .onDisappear {
//            // Stop updating to save battery
//            locationManager.stopUpdatingLocation()
//        }
//    }
//}
//
//
//
