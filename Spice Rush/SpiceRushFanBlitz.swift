import Foundation
import SwiftUI

struct SpiceRushEntryScreen: View {
    @StateObject private var loader: SpiceRushWebLoader

    init(loader: SpiceRushWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            SpiceRushWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                SpiceRushProgressIndicator(value: percent)
            case .failure(let err):
                SpiceRushErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                SpiceRushOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct SpiceRushProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            SpiceRushLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct SpiceRushErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct SpiceRushOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
