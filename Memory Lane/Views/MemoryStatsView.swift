//
//  MemoryStatsView.swift
//  Memory Lane
//
//  Created by Alex on 8/19/25.
//

import SwiftUI

struct MemoryStatsView: View {
    let memories: [Memory]
    
    private var memoryClusters: [(location: String, count: Int)] {
        LocationMatchingService.getMemoryClusters(from: memories)
    }
    
    private var mostVisitedLocation: (location: String, count: Int)? {
        memoryClusters.first
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Basic memory count
            if !memories.isEmpty {
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text("\(memories.count) \(memories.count == 1 ? "memory" : "memories") saved")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    let locatedMemories = memories.filter { $0.hasValidLocation }
                    let accurateMemories = memories.filter { $0.hasValidLocation && $0.accuracy <= 20 }
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .font(.caption2)
                        Text("\(locatedMemories.count) with locations (\(accurateMemories.count) accurate)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(.top, -10)
            }
            
            // Memory location clusters
            if memories.count >= 3 && !memoryClusters.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.green)
                        Text("📊 Memory Locations")
                            .font(.headline)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    
                    if let mostVisited = mostVisitedLocation, mostVisited.count > 1 {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("Most visited: \(mostVisited.count) memories at one location")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    
                    let uniqueLocations = memoryClusters.count
                    HStack {
                        Image(systemName: "map")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("\(uniqueLocations) different location\(uniqueLocations == 1 ? "" : "s") visited")
                            .font(.caption)
                        Spacer()
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    MemoryStatsView(memories: [])
}