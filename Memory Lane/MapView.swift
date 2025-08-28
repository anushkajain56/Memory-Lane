//
//  MapView.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/22/25.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

struct MemoryMapView: View {
    @Binding var memories: [Memory]
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedMemory: Memory?
    @State private var showingMemoryPopup = false
    
    private var memoryLocations: [MemoryLocation] {
        memories.compactMap { memory in
            guard memory.hasValidLocation else { return nil }
            return MemoryLocation(memory: memory)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if memories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "map")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No memories to show")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Create memories with location data to see them on the map")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Map(coordinateRegion: $region, annotationItems: memoryLocations) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            Button(action: {
                                selectedMemory = location.memory
                                showingMemoryPopup = true
                            }) {
                                VStack {
                                    if location.memory.hasPhoto {
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                    } else {
                                        Image(systemName: "note.text")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Memory Map")
            .onAppear {
                updateMapRegion()
            }
        }
        .sheet(isPresented: $showingMemoryPopup) {
            if let memory = selectedMemory {
                MemoryPopupView(memory: memory, isPresented: $showingMemoryPopup)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
            }
        }
    }
    
    private func updateMapRegion() {
        let locatedMemories = memories.filter { $0.hasValidLocation }
        guard !locatedMemories.isEmpty else { return }
        
        let latitudes = locatedMemories.map { $0.latitude }
        let longitudes = locatedMemories.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, 0.01) * 1.2,
            longitudeDelta: max(maxLon - minLon, 0.01) * 1.2
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

struct MemoryLocation: Identifiable {
    let id = UUID()
    let memory: Memory
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: memory.latitude, longitude: memory.longitude)
    }
}
