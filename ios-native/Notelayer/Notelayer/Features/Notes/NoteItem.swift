//
//  NoteItem.swift
//  Notelayer
//
//  Individual note card component
//

import SwiftUI

struct NoteItem: View {
    let note: Note
    var onTap: (() -> Void)?
    var onPin: (() -> Void)?
    var isSelectMode: Bool = false
    var isSelected: Bool = false
    var onSelect: (() -> Void)?
    
    private var preview: String {
        String(note.plainText.prefix(100))
    }
    
    var body: some View {
        Button(action: {
            if isSelectMode {
                onSelect?()
            } else {
                onTap?()
            }
        }) {
            HStack(alignment: .top, spacing: 12) {
                // Icon/Selection indicator
                if isSelectMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .accentColor : .secondary)
                        .font(.system(size: 24))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accent.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "doc.text")
                            .foregroundColor(.accent)
                            .font(.system(size: 20))
                        
                        if note.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.accent)
                                .font(.system(size: 10))
                                .offset(x: 12, y: -12)
                        }
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(note.title.isEmpty ? "Untitled Note" : note.title)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if note.isPinned && !isSelectMode {
                            Text("PINNED")
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                                .foregroundColor(.accent)
                        }
                    }
                    
                    if !preview.isEmpty {
                        Text(preview)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Text(note.updatedAt, style: .relative)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !isSelectMode {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 12))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected && isSelectMode ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button(action: {
                onPin?()
            }) {
                Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
            }
            .tint(.accentColor)
        }
    }
}
