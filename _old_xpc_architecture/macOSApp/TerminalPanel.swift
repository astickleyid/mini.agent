import SwiftUI

struct TerminalPanel: View {

    @ObservedObject var model: DashboardModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("TERMINAL OUTPUT")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.blue)
                .padding(.bottom, 6)
                .padding(.top, 6)

            ScrollView {
                Text(model.terminalOutput)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundColor(.green)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.black)
        }
        .padding()
        .background(Color.black)
    }
}
