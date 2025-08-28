//
//  MemoryBrowseView.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/22/25.
//

import Foundation
import SwiftUI
import CoreLocation
import UIKit

struct MemoryBrowseView: View {
    @Binding var memories: [Memory]

    @State private var selectedMemory: Memory?
    @State private var showingDetail = false
    @State private var searchText = ""

    private var filtered: [Memory] {
        let base = memories.sorted { $0.timestamp > $1.timestamp }
        guard !searchText.isEmpty else { return base }
        return base.filter { m in
            m.title.localizedCaseInsensitiveContains(searchText) ||
            m.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            Group {
                if filtered.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text(memories.isEmpty ? "No memories yet" : "No matches")
                            .font(.headline)
                            .foregroundColor(.primary)
                        if !memories.isEmpty {
                            Text("Try a different search.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                } else {
                    List(filtered, id: \.id) { memory in
                        Button {
                            selectedMemory = memory
                            showingDetail = true
                        } label: {
                            HStack(spacing: 12) {
                                if let photo = memory.photo {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 56, height: 56)
                                        .overlay(
                                            Image(systemName: "note.text")
                                                .foregroundColor(.gray)
                                        )
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(memory.title.isEmpty ? "Untitled Memory" : memory.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    if !memory.content.isEmpty {
                                        Text(memory.content)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                    HStack(spacing: 6) {
                                        Image(systemName: "mappin.circle")
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
                                    .foregroundColor(Color(.tertiaryLabel)) // ✅ wrap UIKit color
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Memories")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
        }
        .sheet(isPresented: $showingDetail) {
            if let m = selectedMemory {
                MemoryPopupView(memory: m, isPresented: $showingDetail)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
            }
        }
    }
}
