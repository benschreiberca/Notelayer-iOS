//
//  NotesView.swift
//  Notelayer
//
//  Notes list view with pinned/unpinned sections
//

import SwiftUI

struct NotesView: View {
    @EnvironmentObject var appStore: AppStore
    @State private var editingNoteId: String? = nil
    @State private var isSelectMode = false
    @State private var selectedNotes: Set<String> = []
    @State private var showDeleteAlert = false
    @State private var noteToDelete: String? = nil
    
    var body: some View {
        NavigationStack {
            List {
                if appStore.notes.isEmpty {
                    Section {
                        VStack(spacing: 16) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No notes yet")
                                .font(.headline)
                            Text("Tap the + button to create your first note")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                } else {
                    // Pinned section
                    if !appStore.pinnedNotes.isEmpty {
                        Section("Pinned") {
                            ForEach(appStore.pinnedNotes) { note in
                                NoteItem(
                                    note: note,
                                    onTap: {
                                        editingNoteId = note.id
                                    },
                                    onPin: {
                                        appStore.togglePinNote(id: note.id)
                                    },
                                    isSelectMode: isSelectMode,
                                    isSelected: selectedNotes.contains(note.id),
                                    onSelect: {
                                        toggleSelect(note.id)
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive, action: {
                                        noteToDelete = note.id
                                        showDeleteAlert = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Unpinned section
                    if !appStore.unpinnedNotes.isEmpty {
                        Section(appStore.pinnedNotes.isEmpty ? "Notes" : "") {
                            ForEach(appStore.unpinnedNotes) { note in
                                NoteItem(
                                    note: note,
                                    onTap: {
                                        editingNoteId = note.id
                                    },
                                    onPin: {
                                        appStore.togglePinNote(id: note.id)
                                    },
                                    isSelectMode: isSelectMode,
                                    isSelected: selectedNotes.contains(note.id),
                                    onSelect: {
                                        toggleSelect(note.id)
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive, action: {
                                        noteToDelete = note.id
                                        showDeleteAlert = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSelectMode {
                        HStack {
                            Text("\(selectedNotes.count) selected")
                                .font(.caption)
                            Button("Done") {
                                exitSelectMode()
                            }
                        }
                    } else {
                        Menu {
                            Button(action: {
                                isSelectMode = true
                            }) {
                                Label("Select Notes", systemImage: "checkmark.circle")
                            }
                            Button(action: {
                                isSelectMode = true
                                selectedNotes = Set(appStore.notes.map { $0.id })
                            }) {
                                Label("Select All", systemImage: "checkmark.circle.fill")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                
                if isSelectMode && !selectedNotes.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(role: .destructive, action: {
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .sheet(item: Binding(
                get: { 
                    if let id = editingNoteId {
                        return NoteEditorState(noteId: id == "new" ? nil : id)
                    }
                    return nil
                },
                set: { editingNoteId = $0?.noteId }
            )) { state in
                NoteEditorView(noteId: state.noteId)
                    .environmentObject(appStore)
            }
            .alert("Delete Note?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    noteToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let id = noteToDelete {
                        appStore.deleteNote(id: id)
                        noteToDelete = nil
                    } else if !selectedNotes.isEmpty {
                        appStore.deleteNotes(ids: Array(selectedNotes))
                        exitSelectMode()
                    }
                }
            } message: {
                if noteToDelete != nil {
                    Text("This action cannot be undone. This note will be permanently deleted.")
                } else {
                    Text("This action cannot be undone. \(selectedNotes.count) note\(selectedNotes.count == 1 ? "" : "s") will be permanently deleted.")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isSelectMode {
                Button(action: {
                    editingNoteId = "new"
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
    }
    
    private func toggleSelect(_ id: String) {
        if selectedNotes.contains(id) {
            selectedNotes.remove(id)
        } else {
            selectedNotes.insert(id)
        }
    }
    
    private func exitSelectMode() {
        isSelectMode = false
        selectedNotes.removeAll()
    }
}

struct NoteEditorState: Identifiable {
    let id = UUID()
    let noteId: String?
}
