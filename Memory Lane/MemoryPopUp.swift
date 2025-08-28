//
//  MemoryPopUp.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/21/25.
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Memory Popup

struct MemoryPopupView: View {
    let memory: Memory
    @Binding var isPresented: Bool

    @State private var showingMemoryPopup = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Memory Found")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text("You've been here before!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        if let photo = memory.photo {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                .scaleEffect(showingMemoryPopup ? 1.0 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingMemoryPopup)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            if !memory.title.isEmpty {
                                Text(memory.title)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                            }

                            if !memory.content.isEmpty {
                                Text(memory.content)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(showingMemoryPopup ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: showingMemoryPopup)
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 5)
        .scaleEffect(showingMemoryPopup ? 1.0 : 0.9)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showingMemoryPopup)
        .onAppear { showingMemoryPopup = true }
    }
}

// MARK: - Sorting options

enum MemorySortOption: String, CaseIterable, Identifiable {
    case dateNewest = "Date (Newest)"
    case dateOldest = "Date (Oldest)"
    case titleAZ    = "Title (A-Z)"
    case titleZA    = "Title (Z-A)"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .dateNewest: return "calendar.badge.clock"
        case .dateOldest: return "calendar"
        case .titleAZ:    return "textformat.abc"
        case .titleZA:    return "textformat.abc.dottedunderline"
        }
    }
}

// MARK: - Memory List

struct MemoryListView: View {
    let memories: [Memory]
    @Binding var isPresented: Bool

    @State private var selectedMemory: Memory?
    @State private var showingMemoryDetail = false

    // Search / filters
    @State private var searchText = ""
    @State private var showPhotosOnly = false
    @State private var showWithLocationOnly = false

    // Sorting
    @State private var sortOption: MemorySortOption = .dateNewest
    @State private var showingSortOptions = false

    // MARK: Sorting
    private var sortedMemories: [Memory] {
        switch sortOption {
        case .dateNewest:
            return memories.sorted { $0.timestamp > $1.timestamp }
        case .dateOldest:
            return memories.sorted { $0.timestamp < $1.timestamp }
        case .titleAZ:
            return memories.sorted {
                let t1 = $0.title.isEmpty ? "Untitled" : $0.title
                let t2 = $1.title.isEmpty ? "Untitled" : $1.title
                return t1.localizedCaseInsensitiveCompare(t2) == .orderedAscending
            }
        case .titleZA:
            return memories.sorted {
                let t1 = $0.title.isEmpty ? "Untitled" : $0.title
                let t2 = $1.title.isEmpty ? "Untitled" : $1.title
                return t1.localizedCaseInsensitiveCompare(t2) == .orderedDescending
            }
        }
    }

    // MARK: Search + filter
    private var filteredMemories: [Memory] {
        var result = sortedMemories

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        if showPhotosOnly {
            result = result.filter { $0.hasPhoto }
        }
        if showWithLocationOnly {
            result = result.filter { $0.hasValidLocation }
        }
        return result
    }

    // MARK: - Helpers (wire up to parent when you add editing)
    private func deleteMemory(_ memory: Memory) {
        // Hook into parent removal if needed
        print("Delete memory: \(memory.title)")
    }

    private func shareMemory(_ memory: Memory) {
        let shareText = "Memory: \(memory.title)\n\(memory.content)\nLocation: \(memory.locationString)\nCreated: \(memory.formattedTimestamp)"
        print("Share memory: \(shareText)")
    }

    var body: some View {
        NavigationView {
            VStack {
                // Stats header
                if !memories.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Your Memory Collection")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }

                        HStack(spacing: 20) {
                            VStack {
                                Text("\(memories.count)")
                                    .font(.title2).fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Total").font(.caption).foregroundColor(.secondary)
                            }
                            VStack {
                                Text("\(memoriesWithPhotos)")
                                    .font(.title2).fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("With Photos").font(.caption).foregroundColor(.secondary)
                            }
                            VStack {
                                Text("\(memoriesWithLocations)")
                                    .font(.title2).fontWeight(.bold)
                                    .foregroundColor(.purple)
                                Text("With Locations").font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                        }

                        if let dateRange = memoryDateRange {
                            Text("From \(dateRange)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top)
                }

                // Empty state
                if memories.isEmpty {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 80))
                                .foregroundColor(.gray.opacity(0.6))

                            VStack(spacing: 8) {
                                Text("No Memories Yet")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Text("Your memory collection is empty")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("How to create memories:")
                                .font(.headline)
                                .foregroundColor(.primary)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    Text("1.")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading) {
                                        Text("Take a photo or choose from library")
                                            .font(.subheadline)
                                        Text("Capture moments at interesting places")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                HStack(alignment: .top) {
                                    Text("2.")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                    VStack(alignment: .leading) {
                                        Text("Add notes and thoughts")
                                            .font(.subheadline)
                                        Text("Write about what makes this place special")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                HStack(alignment: .top) {
                                    Text("3.")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.purple)
                                    VStack(alignment: .leading) {
                                        Text("Save with location")
                                            .font(.subheadline)
                                        Text("Let the app remember where this happened")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                        Button(action: { isPresented = false }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Your First Memory")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(colors: [.blue, .purple],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else {
                    // Search & filters
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                            TextField("Search memories...", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)

                        HStack {
                            Toggle("Photos Only", isOn: $showPhotosOnly).font(.caption)
                            Toggle("With Location", isOn: $showWithLocationOnly).font(.caption)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)

                    // Sort controls
                    HStack {
                        Button {
                            showingSortOptions = true
                        } label: {
                            HStack {
                                Image(systemName: sortOption.systemImage)
                                Text(sortOption.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .confirmationDialog("Sort Memories",
                                            isPresented: $showingSortOptions,
                                            titleVisibility: .visible) {
                            // Explicit buttons = less generic nesting (faster type-check)
                            Button(MemorySortOption.dateNewest.rawValue) { sortOption = .dateNewest }
                            Button(MemorySortOption.dateOldest.rawValue) { sortOption = .dateOldest }
                            Button(MemorySortOption.titleAZ.rawValue)    { sortOption = .titleAZ }
                            Button(MemorySortOption.titleZA.rawValue)    { sortOption = .titleZA }
                            Button("Cancel", role: .cancel) {}
                        }

                        Spacer()

                        Text("\(filteredMemories.count) of \(memories.count) memories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // List (use List initializer instead of List{ForEach} to help the compiler)
                    List(filteredMemories, id: \.id) { memory in
                        MemoryRowView(memory: memory) {
                            selectedMemory = memory
                            showingMemoryDetail = true
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete") { deleteMemory(memory) }
                                .tint(.red)

                            Button("Share") { shareMemory(memory) }
                                .tint(.blue)

                            Button("Details") {
                                selectedMemory = memory
                                showingMemoryDetail = true
                            }
                            .tint(.green)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Memory Lane")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isPresented = false }
                }
            }
        }
        // Detail sheet
        .sheet(isPresented: $showingMemoryDetail) {
            if let memory = selectedMemory {
                MemoryPopupView(memory: memory, isPresented: $showingMemoryDetail)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Stats helpers
    private var memoriesWithPhotos: Int {
        memories.filter { $0.hasPhoto }.count
    }

    private var memoriesWithLocations: Int {
        memories.filter { $0.hasValidLocation }.count
    }

    private var memoryDateRange: String? {
        guard !memories.isEmpty else { return nil }
        let dates = memories.map { $0.timestamp }
        guard let earliest = dates.min(), let latest = dates.max() else { return nil }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return Calendar.current.isDate(earliest, inSameDayAs: latest)
            ? formatter.string(from: earliest)
            : "\(formatter.string(from: earliest)) to \(formatter.string(from: latest))"
    }
}

// MARK: - Row

struct MemoryRowView: View {
    let memory: Memory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail
                if let photo = memory.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: "note.text")
                                .foregroundColor(.gray)
                        }
                }

                // Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title.isEmpty ? "Untitled Memory" : memory.title)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundColor(.primary)

                    if !memory.content.isEmpty {
                        Text(memory.content)
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Image(systemName: "location")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(memory.hasValidLocation ? memory.locationString : "No location")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(memory.formattedTimestamp)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
