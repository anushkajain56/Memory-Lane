//
//  ContentView.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/16/25.
//

import SwiftUI
import CoreLocation
import UIKit
import Foundation
import UserNotifications

struct ContentView: View {
    //Consisten Color Scheme
    private let primaryColor = Color.blue
    private let secondaryColor = Color.purple
    private let accentColor = Color.orange
    private let successColor = Color.green
    private let warningColor = Color.yellow
    private let errorColor = Color.red
    private let lightBackground = Color.blue.opacity(0.1)
    private let mediumBackground = Color.blue.opacity(0.2)
    
    // Typography system constants (add after color constants)
    private let titleFont: Font = .title.weight(.bold)
    private let headlineFont: Font = .headline.weight(.semibold)
    private let bodyFont: Font = .body
    private let captionFont: Font = .caption
    private let buttonFont: Font = .title2.weight(.medium)
    
    // Spacing system constants (add after typography constants)
    private let smallSpacing: CGFloat = 8
    private let mediumSpacing: CGFloat = 16
    private let largeSpacing: CGFloat = 24
    private let extraLargeSpacing: CGFloat = 32

    // Standard padding values
    private let smallPadding: CGFloat = 8
    private let mediumPadding: CGFloat = 16
    private let largePadding: CGFloat = 24

       
    @StateObject private var locationManager = LocationManager()
    private let storageManager = MemoryStorageManager()
    @StateObject private var notificationManager = NotificationManager()

    // App data
    @State private var memories: [Memory] = []

    // Tabs & animated confirmation
    @State private var selectedTab = 0
    @State private var showingSaveConfirmation = false

    // Popup state (for location-triggered popup)
    @State private var showingMemoryPopup = false
    @State private var selectedMemoryForPopup: Memory?
    @State private var lastPopupTime = Date.distantPast
    @State private var shownMemoryIds = Set<UUID>()
    @State private var popupCount = 0
    @State private var lastTriggeredMemoryTitle = ""

    // Trigger behavior
    @State private var triggerCooldown: TimeInterval = 300 // 5 minutes between popups
    @State private var prioritizePhotos: Bool = true

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    // MARK: - Popup / Triggering
    private func showMemoryPopup(for memory: Memory) {
        selectedMemoryForPopup = memory
        showingMemoryPopup = true
        popupCount += 1
        lastTriggeredMemoryTitle = memory.title.isEmpty ? "Untitled Memory" : memory.title

        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            if showingMemoryPopup { withAnimation { showingMemoryPopup = false } }
        }

        print("📱 Showing memory popup #\(popupCount) for: \(lastTriggeredMemoryTitle)")
    }

    private func checkForAutomaticPopups() {
        guard let currentLocation = locationManager.currentLocation else { return }
        guard currentLocation.horizontalAccuracy <= LocationMatching.minimumAccuracy else { return }

        let exactMatches = LocationMatchingService.getMemoriesNear(
            location: currentLocation,
            memories: memories,
            radius: LocationMatching.exactMatchRadius
        )

        if !exactMatches.isEmpty {
            let available = exactMatches.filter { !shownMemoryIds.contains($0.id) }
            if let m = available.sorted(by: { $0.timestamp > $1.timestamp }).first {
                let since = Date().timeIntervalSince(lastPopupTime)
                if since > 300 {
                    notificationManager.scheduleMemoryNotification(for: m, at: currentLocation)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        if !showingMemoryPopup {
                            showMemoryPopup(for: m)
                            shownMemoryIds.insert(m.id)
                            lastPopupTime = Date()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3600) { shownMemoryIds.remove(m.id) }
                        }
                    }
                }
            }
        }
    }

    private func processLocationForMemoryTriggers(_ location: CLLocation) {
        guard location.horizontalAccuracy <= LocationMatching.minimumAccuracy else { return }

        let exactMatches = LocationMatchingService.getMemoriesNear(
            location: location,
            memories: memories,
            radius: LocationMatching.exactMatchRadius
        )

        if !exactMatches.isEmpty {
            triggerMemoryPopup(for: exactMatches, at: location, matchType: .exact)
        } else {
            let nearby = LocationMatchingService.getMemoriesNear(
                location: location,
                memories: memories,
                radius: LocationMatching.nearbyRadius
            )
            if !nearby.isEmpty {
                triggerMemoryPopup(for: nearby, at: location, matchType: .nearby)
            }
        }
    }

    private func triggerMemoryPopup(for matches: [Memory], at location: CLLocation, matchType: LocationMatchType) {
        let since = Date().timeIntervalSince(lastPopupTime)
        if since <= triggerCooldown || showingMemoryPopup {
            print("🚫 Trigger blocked - Cooldown \(Int(since))s / \(Int(triggerCooldown))s")
            return
        }

        let available = matches.filter { !shownMemoryIds.contains($0.id) }
        guard !available.isEmpty else {
            print("⚠️ No available memories to show (recently shown)")
            return
        }

        let selected = available.sorted { a, b in
            if prioritizePhotos && a.hasPhoto != b.hasPhoto { return a.hasPhoto }
            return a.timestamp > b.timestamp
        }.first!

        showMemoryPopup(for: selected)
    }
    
    

    private func handleAppBecameActive() {
        if !locationManager.backgroundTriggerCandidates.isEmpty {
            let candidates = locationManager.backgroundTriggerCandidates
            locationManager.backgroundTriggerCandidates.removeAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if !candidates.isEmpty && !showingMemoryPopup {
                    let best = candidates.sorted { a, b in
                        if a.hasPhoto != b.hasPhoto { return a.hasPhoto }
                        return a.timestamp > b.timestamp
                    }.first!
                    showMemoryPopup(for: best)
                }
            }
        }
    }

    private func startAppStateMonitoring() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in handleAppBecameActive() }
    }

    // Badge helper
    private var memoriesWithLocation: Int {
        memories.filter { $0.hasValidLocation }.count
    }

    // MARK: - View
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                // Create tab with animated jump & confirmation
                CreateMemoryView(allMemories: $memories, onMemorySaved: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedTab = 1
                        showingSaveConfirmation = true
                    }
                    // Hide confirmation after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeOut) { showingSaveConfirmation = false }
                    }
                })
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "plus.circle.fill" : "plus.circle")
                    Text("Create")
                }
                .tag(0)

                // Memories tab (badge only when > 0)
                MemoryBrowseView(memories: $memories)
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "list.bullet.rectangle.fill" : "list.bullet.rectangle")
                        Text("Memories")
                    }
                    .badge(memories.count)
                    .tag(1)

                // Map tab (badge only when > 0)
                MemoryMapView(memories: $memories)
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "map.fill" : "map")
                        Text("Map")
                    }
                    .badge(memoriesWithLocation)
                    .tag(2)
            }
            .animation(.easeInOut(duration: 0.2), value: selectedTab)

            // Save confirmation overlay
            if showingSaveConfirmation {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Memory saved!")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .scaleEffect(showingSaveConfirmation ? 1.0 : 0.8)
                    .opacity(showingSaveConfirmation ? 1.0 : 0.0)
                }
                .padding(.bottom, 100)
            }
        }
        // Popup sheet for location-triggered memory
        .sheet(isPresented: $showingMemoryPopup) {
            if let memory = selectedMemoryForPopup {
                MemoryPopupView(memory: memory, isPresented: $showingMemoryPopup)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
            }
        }
        .onAppear {
            // Load saved memories & wire managers
            memories = storageManager.loadMemories()
            storageManager.printStorageInfo()
            notificationManager.printNotificationStats()
            locationManager.setNotificationManager(notificationManager)
            locationManager.updateSavedMemories(memories)
            startAppStateMonitoring()

            print("\n🚀 MemoryLane System Status:")
            print("   - Memories loaded: \(memories.count)")
            print("   - Location permission: \(locationManager.authorizationStatus.rawValue)")
            print("   - Notification permission: \(notificationManager.notificationPermissionStatus.rawValue)")
            print("   - Background location: \(locationManager.backgroundLocationEnabled)")

            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestLocationPermission()
            } else {
                locationManager.startLocationUpdates()
            }
        }
        .onReceive(locationManager.$currentLocation) { loc in
            guard let loc else { return }
            processLocationForMemoryTriggers(loc)
            checkForAutomaticPopups()
        }
        .onChange(of: locationManager.authorizationStatus) { status in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    if let loc = locationManager.currentLocation {
                        processLocationForMemoryTriggers(loc)
                    }
                }
            }
        }
    }
}
