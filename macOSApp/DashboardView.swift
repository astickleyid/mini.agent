import SwiftUI

struct DashboardView: View {

    @StateObject private var model = DashboardModel()

    var body: some View {
        ZStack {
            Palette.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                header

                HStack(alignment: .top, spacing: 16) {
                    statusPanel
                    TerminalPanel(model: model)
                }

                actionRow
            }
            .padding(24)
        }
        .onAppear { model.refresh() }
    }

    // MARK: Header
    private var header: some View {
        Text("mini.agent Dashboard")
            .foregroundColor(Palette.green)
            .font(.system(size: 26, weight: .bold, design: .monospaced))
    }

    // MARK: Status Panel
    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            panelHeader("Agent Status")

            ForEach(model.statusItems, id: \.self) { item in
                statusRow(title: item)
            }
        }
        .padding(16)
        .frame(maxWidth: 320, alignment: .leading)
        .background(Palette.panel)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.stroke, lineWidth: 1))
        .cornerRadius(12)
    }

    private func statusRow(title: String) -> some View {
        HStack {
            Circle()
                .fill(Palette.green)
                .frame(width: 10, height: 10)
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Palette.grey)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
        }
        .padding(.vertical, 6)
    }

    // MARK: Actions
    private var actionRow: some View {
        HStack(spacing: 14) {
            actionButton("Run Build", color: Palette.blue) { model.runBuild() }
            actionButton("Run Tests", color: Palette.orange) { model.runTests() }
            actionButton("System Status", color: Palette.green) { model.checkSupervisor() }
        }
    }

    private func actionButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .padding(.vertical, 10)
                .frame(minWidth: 140)
                .background(color.opacity(0.2))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(color, lineWidth: 1))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    // MARK: Shared
    private func panelHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .foregroundColor(Palette.grey)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
    }
}

// MARK: - Palette
private enum Palette {
    static let background = Color(red: 0.03, green: 0.03, blue: 0.03)
    static let panel = Color(red: 0.08, green: 0.08, blue: 0.08)
    static let stroke = Color.white.opacity(0.1)
    static let grey = Color(red: 0.69, green: 0.69, blue: 0.69)
    static let green = Color(red: 0.0, green: 1.0, blue: 0.4) // #00FF66
    static let blue = Color(red: 0.04, green: 0.52, blue: 1.0) // #0A84FF
    static let orange = Color(red: 1.0, green: 0.58, blue: 0.0) // #FF9500
}
