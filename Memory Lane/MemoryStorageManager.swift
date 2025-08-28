//
//  MemoryStorageManager.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/19/25.
//
import Foundation
import CoreLocation

class MemoryStorageManager {
    private let userDefaults = UserDefaults.standard
    private let storageKey = "SavedMemories"
    
    func saveMemories(_ memories: [Memory]) {
        do {
            let data = try JSONEncoder().encode(memories)
            userDefaults.set(data, forKey: storageKey)
            print("✅ Saved \(memories.count) memories to storage")
        } catch {
            print("❌ Failed to save memories: \(error.localizedDescription)")
        }
    }
    
    func loadMemories() -> [Memory] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            print("📝 No saved memories found")
            return []
        }
        
        do {
            let memories = try JSONDecoder().decode([Memory].self, from: data)
            print("✅ Loaded \(memories.count) memories from storage")
            return memories
        } catch {
            print("❌ Failed to load memories: \(error.localizedDescription)")
            return []
        }
    }
    
    func clearAllMemories() {
        userDefaults.removeObject(forKey: storageKey)
        print("🗑️ Cleared all saved memories")
    }
    
    
    
    func printStorageInfo() {
        let data = userDefaults.data(forKey: storageKey)
        if let data = data {
            let sizeInBytes = data.count
            let sizeInKB = Double(sizeInBytes) / 1024.0
            print("💾 Storage Info:")
            print("   - Size: \(String(format: "%.1f", sizeInKB)) KB (\(sizeInBytes) bytes)")
            print("   - Key: \(storageKey)")
            
            do {
                let memories = try JSONDecoder().decode([Memory].self, from: data)
                print("   - Total memories: \(memories.count)")
                print("   - With photos: \(memories.filter { $0.photoData != nil }.count)")
                
                let locatedMemories = memories.filter { $0.hasValidLocation }
                print("\n📍 Location Matching Analysis:")
                print("   - Valid locations: \(locatedMemories.count)")
                
                if !locatedMemories.isEmpty {
                    let accuracies = locatedMemories.map { $0.accuracy }
                    let avgAccuracy = accuracies.reduce(0, +) / Double(accuracies.count)
                    let bestAccuracy = accuracies.min() ?? 0
                    let worstAccuracy = accuracies.max() ?? 0
                    
                    print("   - Average accuracy: ±\(String(format: "%.1f", avgAccuracy))m")
                    print("   - Best accuracy: ±\(String(format: "%.1f", bestAccuracy))m")
                    print("   - Worst accuracy: ±\(String(format: "%.1f", worstAccuracy))m")
                    
                    let matchableMemories = locatedMemories.filter { $0.accuracy <= LocationMatching.minimumAccuracy }
                    print("   - Matchable memories: \(matchableMemories.count) (accuracy ≤ \(Int(LocationMatching.minimumAccuracy))m)")
                    
                    let highAccuracyMemories = locatedMemories.filter { $0.accuracy <= LocationMatching.highAccuracyThreshold }
                    print("   - High accuracy memories: \(highAccuracyMemories.count) (accuracy ≤ \(Int(LocationMatching.highAccuracyThreshold))m)")

                    let notificationEligible = locatedMemories.filter { $0.accuracy <= 20.0 }
                    print("   - Notification eligible: \(notificationEligible.count) (accuracy ≤ 20m)")
                    
                    // Analyze potential matches between memories
                    var potentialMatches = 0
                    for i in 0..<matchableMemories.count {
                        for j in (i+1)..<matchableMemories.count {
                            let memory1 = matchableMemories[i]
                            let memory2 = matchableMemories[j]
                            let location1 = CLLocation(latitude: memory1.latitude, longitude: memory1.longitude)
                            let location2 = CLLocation(latitude: memory2.latitude, longitude: memory2.longitude)
                            let distance = location1.distance(from: location2)
                            
                            if distance <= LocationMatching.nearbyRadius {
                                potentialMatches += 1
                            }
                        }
                    }
                    print("   - Memory clusters: \(potentialMatches) nearby pairs")
                }
                
            } catch {
                print("   - Error reading data: \(error.localizedDescription)")
            }
        } else {
            print("💾 No storage data found")
        }
        // Call notification debugging
        NotificationManager().printNotificationStats() // compiles but uses a fresh manager

    }
}
