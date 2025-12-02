import SwiftUI

// Browser-style tab view with drag-to-reorder
struct FlexibleTabView: View {
    @StateObject private var tabManager = TabManager.shared
    @State private var selectedTab: TabItem?
    @State private var showAddTab = false
    @State private var draggedTab: TabItem?
    @State private var hoveredIndex: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            TabBar(
                tabs: tabManager.tabs,
                selectedTab: $selectedTab,
                draggedTab: $draggedTab,
                hoveredIndex: $hoveredIndex,
                onSelectTab: { selectedTab = $0 },
                onCloseTab: { tab in
                    if selectedTab?.id == tab.id {
                        let index = tabManager.tabs.firstIndex(where: { $0.id == tab.id }) ?? 0
                        let newIndex = index > 0 ? index - 1 : (tabManager.tabs.count > 1 ? 1 : -1)
                        selectedTab = newIndex >= 0 ? tabManager.tabs[newIndex] : nil
                    }
                    tabManager.removeTab(tab)
                },
                onReorderTab: { from, to in
                    tabManager.moveTab(from: from, to: to)
                },
                onDetachTab: { tabManager.detachTab($0) },
                onAddTab: { showAddTab = true }
            )
            
            // Content area
            ZStack {
                if let selectedTab = selectedTab {
                    TabContentView(type: selectedTab.type)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    EmptyTabView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if selectedTab == nil {
                selectedTab = tabManager.tabs.first
            }
        }
        .sheet(isPresented: $showAddTab) {
            AddTabSheet(selectedTab: $selectedTab)
        }
    }
}

struct TabBar: View {
    let tabs: [TabItem]
    @Binding var selectedTab: TabItem?
    @Binding var draggedTab: TabItem?
    @Binding var hoveredIndex: Int?
    let onSelectTab: (TabItem) -> Void
    let onCloseTab: (TabItem) -> Void
    let onReorderTab: (Int, Int) -> Void
    let onDetachTab: (TabItem) -> Void
    let onAddTab: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: -1) {
                        ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                            BrowserTab(
                                tab: tab,
                                isSelected: selectedTab?.id == tab.id,
                                isDragging: draggedTab?.id == tab.id,
                                tabIndex: index,
                                draggedTab: $draggedTab,
                                hoveredIndex: $hoveredIndex,
                                onSelect: { onSelectTab(tab) },
                                onClose: { onCloseTab(tab) },
                                onReorder: onReorderTab,
                                onDetach: { onDetachTab(tab) }
                            )
                            .id(tab.id)
                        }
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 4)
                }
            }
            
            // Add tab button
            Button(action: onAddTab) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
        }
        .frame(height: 36)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

struct BrowserTab: View {
    let tab: TabItem
    let isSelected: Bool
    let isDragging: Bool
    let tabIndex: Int
    @Binding var draggedTab: TabItem?
    @Binding var hoveredIndex: Int?
    let onSelect: () -> Void
    let onClose: () -> Void
    let onReorder: (Int, Int) -> Void
    let onDetach: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isHovered = false
    
    private let tabWidth: CGFloat = 140
    
    var body: some View {
        HStack(spacing: 8) {
            Text(tab.icon)
                .font(.system(size: 14))
            
            Text(tab.title)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if isHovered || isSelected {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 14, height: 14)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: tabWidth)
        .background(
            ZStack {
                if isSelected {
                    Color(NSColor.controlBackgroundColor)
                } else if isHovered {
                    Color(NSColor.separatorColor).opacity(0.3)
                } else {
                    Color.clear
                }
            }
        )
        .clipShape(TabShape())
        .overlay(
            TabShape()
                .stroke(
                    isSelected ? Color(NSColor.separatorColor) : Color.clear,
                    lineWidth: 0.5
                )
        )
        .offset(x: dragOffset)
        .opacity(isDragging ? 0.7 : 1.0)
        .zIndex(isDragging ? 1 : (isSelected ? 0.5 : 0))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onSelect()
        }
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    if draggedTab == nil {
                        draggedTab = tab
                    }
                    
                    if draggedTab?.id == tab.id {
                        dragOffset = value.translation.width
                        
                        // Calculate hovered index for reordering
                        let dragDistance = value.translation.width
                        let tabsToMove = Int(round(dragDistance / tabWidth))
                        let newIndex = max(0, min(tabIndex + tabsToMove, hoveredIndex ?? tabIndex))
                        hoveredIndex = newIndex
                    }
                }
                .onEnded { value in
                    guard draggedTab?.id == tab.id else { return }
                    
                    // Check for detach (vertical drag)
                    if abs(value.translation.height) > 40 {
                        onDetach()
                        draggedTab = nil
                        hoveredIndex = nil
                        dragOffset = 0
                        return
                    }
                    
                    // Reorder tabs
                    if let targetIndex = hoveredIndex, targetIndex != tabIndex {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onReorder(tabIndex, targetIndex > tabIndex ? targetIndex + 1 : targetIndex)
                        }
                    }
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        dragOffset = 0
                        draggedTab = nil
                        hoveredIndex = nil
                    }
                }
        )
        .contextMenu {
            Button("Open in New Window") {
                onDetach()
            }
            Button("Close Tab") {
                onClose()
            }
        }
    }
}

// Custom tab shape with rounded top corners
struct TabShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 6
        
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        return path
    }
}

struct TabContentView: View {
    let type: TabType
    
    var body: some View {
        Group {
            switch type {
            case .aiTools:
                AIToolsConfigView()
            case .commands:
                CommandsConfigView()
            case .projects:
                ProjectsConfigView()
            case .preferences:
                PreferencesConfigView()
            case .dashboard:
                DashboardView()
            case .generate:
                GenerateView()
            case .knowledge:
                KnowledgeView()
            }
        }
    }
}

struct EmptyTabView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No tabs open")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Click + to add a tab")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddTabSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tabManager = TabManager.shared
    @Binding var selectedTab: TabItem?
    
    let availableTabs: [(TabType, String, String)] = [
        (.dashboard, "Dashboard", "square.grid.2x2"),
        (.aiTools, "AI Tools", "cpu"),
        (.commands, "Commands", "terminal"),
        (.projects, "Projects", "folder"),
        (.generate, "Generate Code", "wand.and.stars"),
        (.knowledge, "Knowledge Base", "book"),
        (.preferences, "Preferences", "gearshape")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(availableTabs, id: \.0) { type, title, icon in
                    Button(action: {
                        let newTab = tabManager.addTab(type: type)
                        selectedTab = newTab
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: icon)
                                .frame(width: 30)
                            Text(title)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Add Tab")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
    }
}

// MARK: - Tab Manager

class TabManager: ObservableObject {
    static let shared = TabManager()
    
    @Published var tabs: [TabItem] = []
    
    init() {
        // Default tabs
        tabs = [
            TabItem(type: .dashboard),
            TabItem(type: .aiTools),
            TabItem(type: .commands)
        ]
    }
    
    @discardableResult
    func addTab(type: TabType) -> TabItem {
        let newTab = TabItem(type: type)
        tabs.append(newTab)
        return newTab
    }
    
    func removeTab(_ tab: TabItem) {
        tabs.removeAll { $0.id == tab.id }
    }
    
    func detachTab(_ tab: TabItem) {
        // Open in new window
        let window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = tab.title
        window.contentView = NSHostingView(rootView: TabContentView(type: tab.type))
        window.makeKeyAndOrderFront(nil)
        
        // Remove from main window
        removeTab(tab)
    }
    
    func moveTab(from: Int, to: Int) {
        tabs.move(fromOffsets: IndexSet(integer: from), toOffset: to)
    }
}

// MARK: - Models

enum TabType: Hashable {
    case dashboard
    case aiTools
    case commands
    case projects
    case generate
    case knowledge
    case preferences
}

struct TabItem: Identifiable, Hashable {
    let id = UUID()
    let type: TabType
    
    var title: String {
        switch type {
        case .dashboard: return "Dashboard"
        case .aiTools: return "AI Tools"
        case .commands: return "Commands"
        case .projects: return "Projects"
        case .generate: return "Generate"
        case .knowledge: return "Knowledge"
        case .preferences: return "Preferences"
        }
    }
    
    var icon: String {
        switch type {
        case .dashboard: return "📊"
        case .aiTools: return "🤖"
        case .commands: return "⚡"
        case .projects: return "📁"
        case .generate: return "✨"
        case .knowledge: return "📚"
        case .preferences: return "⚙️"
        }
    }
}

// MARK: - Placeholder views

struct GenerateView: View {
    var body: some View {
        VStack {
            Text("Generate Code")
                .font(.title)
            Text("Coming soon...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct KnowledgeView: View {
    var body: some View {
        VStack {
            Text("Knowledge Base")
                .font(.title)
            Text("Coming soon...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FlexibleTabView()
}
