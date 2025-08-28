//
//  MemoryCaptureView.swift
//  Memory Lane
//
//  Created by Alex on 8/19/25.
//

import SwiftUI
import UIKit
import CoreLocation

struct MemoryCaptureView: View {
    @Binding var selectedImage: UIImage?
    @Binding var noteTitle: String
    @Binding var noteContent: String
    @Binding var hasNote: Bool
    @Binding var showingImagePicker: Bool
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var showingNoteEditor: Bool
    @ObservedObject var locationManager: LocationManager
    
    private var hasValidLocation: Bool {
        return locationManager.currentLocation != nil &&
               (locationManager.currentLocation!.coordinate.latitude != 0.0 ||
                locationManager.currentLocation!.coordinate.longitude != 0.0)
    }
    
    private var currentLocationString: String {
        guard let location = locationManager.currentLocation else {
            return "No location"
        }
        return String(format: "%.4f, %.4f", location.coordinate.latitude, location.coordinate.longitude)
    }
    
    private func canSaveMemory() -> Bool {
        let hasPhoto = selectedImage != nil
        let hasTitle = !noteTitle.isEmpty
        let hasContent = !noteContent.isEmpty
        let hasLocation = hasValidLocation
        return hasLocation && (hasPhoto || hasTitle || hasContent)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Memory Preview
            if canSaveMemory() {
                MemoryPreviewView(
                    selectedImage: selectedImage,
                    noteTitle: noteTitle,
                    noteContent: noteContent,
                    currentLocationString: currentLocationString,
                    locationManager: locationManager
                )
            }
            
            // Captured Photo Display
            if let image = selectedImage {
                CapturedPhotoView(image: image) {
                    selectedImage = nil
                }
            }
            
            // Notes Display
            if hasNote && (!noteTitle.isEmpty || !noteContent.isEmpty) {
                CapturedNotesView(
                    noteTitle: noteTitle,
                    noteContent: noteContent
                ) {
                    noteTitle = ""
                    noteContent = ""
                    hasNote = false
                }
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: { showingNoteEditor = true }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text(hasNote ? "Edit Notes" : "Add Notes")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                
                HStack(spacing: 16) {
                    Button(action: { sourceType = .camera; showingImagePicker = true }) {
                        HStack {
                            Image(systemName: UIImagePickerController.isSourceTypeAvailable(.camera) ? "camera.fill" : "camera.fill")
                            Text(UIImagePickerController.isSourceTypeAvailable(.camera) ? "Take Photo" : "Camera Not Available")
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(UIImagePickerController.isSourceTypeAvailable(.camera) ? Color.green : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    
                    Button(action: { sourceType = .photoLibrary; showingImagePicker = true }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Choose Photo")
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
}

struct MemoryPreviewView: View {
    let selectedImage: UIImage?
    let noteTitle: String
    let noteContent: String
    let currentLocationString: String
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "eye")
                    .foregroundColor(.blue)
                Text("Memory Preview")
                    .font(.headline)
                    .foregroundColor(.blue)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(noteTitle.isEmpty ? "Memory at \(currentLocationString)" : noteTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100, maxHeight: 60)
                        .cornerRadius(6)
                }
                
                if !noteContent.isEmpty {
                    Text(noteContent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "location.circle")
                            .foregroundColor(.blue)
                        Text("📍 \(currentLocationString)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    if let location = locationManager.currentLocation {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.green)
                                .font(.caption2)
                            Text("Accuracy: ±\(Int(location.horizontalAccuracy))m")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CapturedPhotoView: View {
    let image: UIImage
    let onClear: () -> Void
    
    var body: some View {
        VStack {
            Text("📸 Captured Memory")
                .font(.headline)
                .foregroundColor(.green)
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, maxHeight: 200)
                .cornerRadius(12)
                .shadow(radius: 4)
            
            Button(action: onClear) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Clear Photo")
                }
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top, 8)
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

struct CapturedNotesView: View {
    let noteTitle: String
    let noteContent: String
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.orange)
                Text("📝 Memory Notes")
                    .font(.headline)
                    .foregroundColor(.orange)
                Spacer()
            }
            
            if !noteTitle.isEmpty {
                Text(noteTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
            }
            
            if !noteContent.isEmpty {
                Text(noteContent)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(6)
            }
            
            Button(action: onClear) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Clear Notes")
                }
                .font(.caption)
                .foregroundColor(.red)
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    MemoryCaptureView(
        selectedImage: .constant(nil),
        noteTitle: .constant(""),
        noteContent: .constant(""),
        hasNote: .constant(false),
        showingImagePicker: .constant(false),
        sourceType: .constant(.camera),
        showingNoteEditor: .constant(false),
        locationManager: LocationManager()
    )
}
