//
//  NoteEditorView.swift
//  Memory Lane
//
//  Created by Anushka Jain on 8/19/25.
//

import Foundation
import SwiftUI

struct NoteEditorView: View {
    @Binding var title: String
    @Binding var content: String
    @Binding var isPresented: Bool
    @Binding var hasNote: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Memory Title")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter a title for this memory...", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .frame(minHeight: 200)
                            .font(.body)
                        
                        if content.isEmpty {
                            Text("What happened at this location? Describe your memory, thoughts, or feelings about this place...")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .font(.body)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                HStack {
                    Spacer()
                    Text("Characters: \(content.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                
                
                
                Spacer()
            }
            
            
            .padding()
            
            .onTapGesture {
                hideKeyboard()
            }
            
            
            .navigationTitle("Memory Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        hasNote = !title.isEmpty || !content.isEmpty
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
