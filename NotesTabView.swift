import SwiftUI

// ========================================
// NOTES TAB VIEW
// ========================================

struct NotesTabView: View {
    
    @ObservedObject var manager: FocusModeTimer
    
    @State private var searchText = ""
    @State private var showNewNote = false
    @State private var selectedFilter: SessionCategory? = nil
    @State private var editingNote: NoteEntry? = nil
    @State private var sortNewestFirst = true
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                
                if manager.notes.isEmpty && searchText.isEmpty {
                    emptyState
                } else {
                    notesList
                }
                
                // floating add button
                addButton
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes…")
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    sortMenu
                }
            }
            .sheet(isPresented: $showNewNote) {
                NoteEditorView(
                    manager: manager,
                    existingNote: nil,
                    defaultTask: manager.currentTaskName,
                    defaultCategory: manager.selectedCategory
                )
            }
            .sheet(item: $editingNote) { note in
                NoteEditorView(
                    manager: manager,
                    existingNote: note,
                    defaultTask: "",
                    defaultCategory: note.category
                )
            }
        }
    }
    
    // ========================================
    // EMPTY STATE
    // ========================================
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(.secondary.opacity(0.4))
            Text("No Notes Yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Capture ideas, session reflections,\nor anything on your mind.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showNewNote = true
            } label: {
                Label("Create First Note", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(24)
            }
            .padding(.top, 8)
            Spacer()
        }
        .padding()
    }
    
    // ========================================
    // NOTES LIST
    // ========================================
    
    private var notesList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                
                // category filter chips
                categoryFilters
                
                // stats bar
                statsBar
                
                // pinned section
                let pinned = filteredNotes.filter(\.isPinned)
                if !pinned.isEmpty {
                    sectionHeader(title: "Pinned", icon: "pin.fill", color: .orange)
                    ForEach(pinned) { note in
                        noteCard(note)
                    }
                }
                
                // recent section
                let unpinned = filteredNotes.filter { !$0.isPinned }
                if !unpinned.isEmpty {
                    sectionHeader(title: "Recent", icon: "clock.fill", color: .blue)
                    ForEach(unpinned) { note in
                        noteCard(note)
                    }
                }
                
                // bottom padding for FAB
                Spacer().frame(height: 80)
            }
            .padding()
        }
    }
    
    // ========================================
    // CATEGORY FILTER CHIPS
    // ========================================
    
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "All", icon: "tray.fill", color: .blue, isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                
                ForEach(SessionCategory.allCases, id: \.self) { category in
                    filterChip(
                        label: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedFilter == category
                    ) {
                        selectedFilter = selectedFilter == category ? nil : category
                    }
                }
            }
        }
    }
    
    private func filterChip(label: String, icon: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) { action() }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? color.opacity(0.2) : Color(UIColor.tertiarySystemBackground))
            .foregroundStyle(isSelected ? color : .secondary)
            .cornerRadius(20)
            .overlay(
                Capsule().stroke(isSelected ? color.opacity(0.3) : .clear, lineWidth: 1)
            )
        }
    }
    
    // ========================================
    // STATS BAR
    // ========================================
    
    private var statsBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 5) {
                Image(systemName: "doc.text.fill")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                Text("\(manager.notes.count) notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            let totalWords = manager.notes.reduce(0) { $0 + $1.content.split(separator: " ").count + $1.title.split(separator: " ").count }
            HStack(spacing: 5) {
                Image(systemName: "text.word.spacing")
                    .font(.caption2)
                    .foregroundStyle(.purple)
                Text("\(totalWords) words")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            let pinnedCount = manager.notes.filter(\.isPinned).count
            if pinnedCount > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(pinnedCount) pinned")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    // ========================================
    // NOTE CARD
    // ========================================
    
    private func noteCard(_ note: NoteEntry) -> some View {
        Button {
            editingNote = note
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // header
                HStack(spacing: 8) {
                    Circle()
                        .fill(colorForTag(note.colorTag))
                        .frame(width: 8, height: 8)
                    
                    Text(note.title.isEmpty ? "Untitled" : note.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    
                    Image(systemName: note.category.icon)
                        .font(.caption2)
                        .foregroundStyle(note.category.color)
                }
                
                // content preview
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // footer
                HStack(spacing: 10) {
                    // linked task
                    if !note.linkedTask.isEmpty {
                        HStack(spacing: 3) {
                            Image(systemName: "link")
                                .font(.system(size: 9))
                            Text(note.linkedTask)
                                .font(.system(size: 10))
                        }
                        .foregroundStyle(.blue.opacity(0.7))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.06))
                        .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    // word count
                    let words = note.content.split(separator: " ").count
                    Text("\(words) words")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary.opacity(0.6))
                    
                    // date
                    Text(note.date, style: .relative)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary.opacity(0.6))
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(14)
        }
        .contextMenu {
            Button {
                manager.toggleNotePin(id: note.id)
            } label: {
                Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash.fill" : "pin.fill")
            }
            
            Menu("Color") {
                ForEach(["blue", "purple", "green", "orange", "red", "pink"], id: \.self) { color in
                    Button {
                        manager.updateNoteColor(id: note.id, color: color)
                    } label: {
                        Label(color.capitalized, systemImage: "circle.fill")
                    }
                }
            }
            
            Button {
                UIPasteboard.general.string = "\(note.title)\n\n\(note.content)"
            } label: {
                Label("Copy Text", systemImage: "doc.on.doc")
            }
            
            Divider()
            
            Button(role: .destructive) {
                withAnimation {
                    manager.deleteNote(id: note.id)
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
    
    // ========================================
    // SECTION HEADER
    // ========================================
    
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.top, 4)
    }
    
    // ========================================
    // SORT MENU
    // ========================================
    
    private var sortMenu: some View {
        Menu {
            Button {
                sortNewestFirst = true
            } label: {
                Label("Newest First", systemImage: sortNewestFirst ? "checkmark" : "")
            }
            Button {
                sortNewestFirst = false
            } label: {
                Label("Oldest First", systemImage: !sortNewestFirst ? "checkmark" : "")
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.subheadline)
        }
    }
    
    // ========================================
    // FLOATING ADD BUTTON
    // ========================================
    
    private var addButton: some View {
        Button {
            showNewNote = true
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Circle())
                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 16)
    }
    
    // ========================================
    // HELPERS
    // ========================================
    
    private var filteredNotes: [NoteEntry] {
        var result = manager.notes
        
        // category filter
        if let filter = selectedFilter {
            result = result.filter { $0.category == filter }
        }
        
        // search filter
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.content.lowercased().contains(query) ||
                $0.linkedTask.lowercased().contains(query)
            }
        }
        
        // sort
        result.sort { a, b in
            if a.isPinned != b.isPinned { return a.isPinned }
            return sortNewestFirst ? a.date > b.date : a.date < b.date
        }
        
        return result
    }
    
    private func colorForTag(_ tag: String) -> Color {
        switch tag {
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .blue
        }
    }
}

// ==============================================
// NOTE EDITOR VIEW (Sheet)
// ==============================================

struct NoteEditorView: View {
    
    @ObservedObject var manager: FocusModeTimer
    @Environment(\.dismiss) var dismiss
    
    let existingNote: NoteEntry?
    let defaultTask: String
    let defaultCategory: SessionCategory
    
    @State private var title = ""
    @State private var content = ""
    @State private var category: SessionCategory = .study
    @State private var linkedTask = ""
    @State private var colorTag = "blue"
    @State private var isPinned = false
    @FocusState private var contentFocused: Bool
    
    private var isEditing: Bool { existingNote != nil }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    
                    // title field
                    TextField("Note title", text: $title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    Divider()
                    
                    // content field
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Write something…")
                                .foregroundStyle(.secondary.opacity(0.5))
                                .padding(.top, 8)
                        }
                        
                        TextEditor(text: $content)
                            .focused($contentFocused)
                            .frame(minHeight: 200)
                            .scrollContentBackground(.hidden)
                    }
                    
                    Divider()
                    
                    // metadata section
                    VStack(spacing: 14) {
                        
                        // category picker
                        HStack {
                            Label("Category", systemImage: "tag.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Picker("Category", selection: $category) {
                                ForEach(SessionCategory.allCases, id: \.self) { cat in
                                    Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                                }
                            }
                            .tint(category.color)
                        }
                        
                        // linked task
                        HStack {
                            Label("Linked Task", systemImage: "link")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            TextField("Optional", text: $linkedTask)
                                .multilineTextAlignment(.trailing)
                                .font(.subheadline)
                                .frame(maxWidth: 180)
                        }
                        
                        // color tag
                        HStack {
                            Label("Color", systemImage: "paintpalette.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            HStack(spacing: 8) {
                                ForEach(["blue", "purple", "green", "orange", "red", "pink"], id: \.self) { color in
                                    Circle()
                                        .fill(colorForTag(color))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.primary, lineWidth: colorTag == color ? 2 : 0)
                                                .padding(colorTag == color ? -2 : 0)
                                        )
                                        .onTapGesture {
                                            colorTag = color
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                }
                            }
                        }
                        
                        // pin toggle
                        Toggle(isOn: $isPinned) {
                            Label("Pin Note", systemImage: "pin.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .tint(.orange)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(14)
                    
                    // word count
                    HStack {
                        Spacer()
                        let words = content.split(separator: " ").count
                        let chars = content.count
                        Text("\(words) words · \(chars) characters")
                            .font(.caption)
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveNote()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
            .onAppear { loadExisting() }
        }
    }
    
    private func loadExisting() {
        if let note = existingNote {
            title = note.title
            content = note.content
            category = note.category
            linkedTask = note.linkedTask
            colorTag = note.colorTag
            isPinned = note.isPinned
        } else {
            category = defaultCategory
            linkedTask = defaultTask
        }
    }
    
    private func saveNote() {
        if let existing = existingNote {
            var updated = existing
            updated.title = title
            updated.content = content
            updated.category = category
            updated.linkedTask = linkedTask
            updated.colorTag = colorTag
            updated.isPinned = isPinned
            manager.updateNote(updated)
        } else {
            let note = NoteEntry(
                title: title,
                content: content,
                category: category,
                date: Date(),
                isPinned: isPinned,
                linkedTask: linkedTask,
                colorTag: colorTag
            )
            manager.addNote(note)
        }
    }
    
    private func colorForTag(_ tag: String) -> Color {
        switch tag {
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .blue
        }
    }
}
