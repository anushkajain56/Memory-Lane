import SwiftUI
import CoreLocation
import UIKit
import Foundation

struct CreateMemoryView: View {
    // Location + storage
    @StateObject private var locationManager = LocationManager()
    private let storageManager = MemoryStorageManager()

    // Bind to app’s memory array
    @Binding var allMemories: [Memory]

    // Callback so ContentView can switch to “Memories” tab after saving
    var onMemorySaved: (() -> Void)? = nil

    // Photo selection
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    // Notes
    @State private var showingNoteEditor = false
    @State private var noteTitle = ""
    @State private var noteContent = ""
    @State private var hasNote = false

    // MARK: - Helpers

    private var hasValidLocation: Bool {
        if let loc = locationManager.currentLocation {
            return !(loc.coordinate.latitude == 0 && loc.coordinate.longitude == 0)
        }
        return false
    }

    private var currentLocationString: String {
        guard let loc = locationManager.currentLocation else { return "No location" }
        return String(format: "%.6f, %.6f", loc.coordinate.latitude, loc.coordinate.longitude)
    }

    private func canSaveMemory() -> Bool {
        let hasPhoto = selectedImage != nil
        let hasTitle = !noteTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasContent = !noteContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasValidLocation && (hasPhoto || hasTitle || hasContent)
    }

    // MARK: - Save

    private func saveCurrentMemory() {
        guard let currentLocation = locationManager.currentLocation else {
            print("❌ Cannot save memory: No location available")
            return
        }

        guard hasValidLocation else {
            print("❌ Cannot save memory: Invalid location data")
            return
        }

        let memory = Memory(
            photo: selectedImage,
            title: noteTitle.isEmpty ? "Memory at \(currentLocationString)" : noteTitle,
            content: noteContent,
            location: currentLocation
        )

        print("📍 Saving memory at: \(String(format: "%.4f, %.4f", memory.latitude, memory.longitude))")
        print("📏 Location accuracy: ±\(Int(memory.accuracy))m")

        allMemories.append(memory)
        storageManager.saveMemories(allMemories)
        locationManager.updateSavedMemories(allMemories)

        // Clear inputs
        selectedImage = nil
        noteTitle = ""
        noteContent = ""
        hasNote = false

        // Notify parent
        onMemorySaved?()
    }

    // MARK: - View

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create Memory")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)

                    // Memory count display
                    if !allMemories.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text("\(allMemories.count) \(allMemories.count == 1 ? "memory" : "memories") saved")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, -10)
                    }

                    // Location display
                    VStack(spacing: 12) {
                        Text("Current Location")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        if let location = locationManager.currentLocation {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Latitude:").fontWeight(.medium)
                                    Spacer()
                                    Text("\(location.coordinate.latitude, specifier: "%.6f")")
                                        .font(.system(.body, design: .monospaced))
                                }
                                HStack {
                                    Text("Longitude:").fontWeight(.medium)
                                    Spacer()
                                    Text("\(location.coordinate.longitude, specifier: "%.6f")")
                                        .font(.system(.body, design: .monospaced))
                                }
                                HStack {
                                    Text("Accuracy:").fontWeight(.medium)
                                    Spacer()
                                    Text("±\(Int(location.horizontalAccuracy)) m")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        } else {
                            Text("Location not available")
                                .foregroundColor(.gray)
                                .italic()
                        }
                    }
                    .padding(.horizontal)

                    // Photo picker
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Photo (optional)")
                                .font(.headline)
                            Spacer()
                            Menu {
                                Button {
                                    sourceType = .camera
                                    showingImagePicker = true
                                } label: {
                                    Label("Camera", systemImage: "camera")
                                }
                                Button {
                                    sourceType = .photoLibrary
                                    showingImagePicker = true
                                } label: {
                                    Label("Photo Library", systemImage: "photo.on.rectangle")
                                }
                            } label: {
                                Label(selectedImage == nil ? "Add Photo" : "Change Photo",
                                      systemImage: "plus.circle")
                                    .font(.subheadline)
                            }
                        }

                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 220)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.12))
                                .frame(height: 120)
                                .overlay(
                                    VStack(spacing: 6) {
                                        Image(systemName: "photo.on.rectangle")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                        Text("No photo selected")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        }
                    }
                    .padding(.horizontal)

                    // Notes
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Title (optional)", text: $noteTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextEditor(text: $noteContent)
                            .frame(minHeight: 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)

                    // Save
                    Button(action: saveCurrentMemory) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Save Memory")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(canSaveMemory() ? Color.indigo : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!canSaveMemory())
                    .padding(.horizontal)

                    Spacer(minLength: 24)
                }
            }
            .navigationTitle("New Memory")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(
                selectedImage: $selectedImage,
                isPresented: $showingImagePicker,
                sourceType: sourceType
            )
        }
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestLocationPermission()
            } else {
                locationManager.startLocationUpdates()
            }
        }
    }
}
