import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct SpiceRushLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var angle: Double = 0
    @State private var glow: Bool = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Animated gradient background (no images)
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#0B1020"),
                        Color(hex: "#111827"),
                        Color(hex: "#0E1B2A"),
                        Color(hex: "#0B1020"),
                    ]),
                    center: .center,
                    angle: .degrees(angle)
                )
                .ignoresSafeArea()
                .animation(.linear(duration: 12).repeatForever(autoreverses: false), value: angle)
                .onAppear { angle = 360 }

                VStack(spacing: 28) {
                    // Circular spinner
                    SpiceRushCircularSpinner(progress: progress)
                        .frame(width: min(geo.size.width, geo.size.height) * 0.32,
                               height: min(geo.size.width, geo.size.height) * 0.32)
                        .shadow(color: Color.white.opacity(glow ? 0.35 : 0.1), radius: glow ? 24 : 8)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glow)
                        .onAppear { glow = true }

                    // English text only
                    VStack(spacing: 8) {
                        Text("Loading SpiceRush...")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 1)

                        Text("\(progressPercentage)%")
                            .font(.system(size: 20, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [Color.cyan.opacity(0.25), Color.purple.opacity(0.1)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                    )
                    .cornerRadius(14)
                }
            }
        }
    }
}

// MARK: - Фоновые представления

struct SpiceRushBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#0B0F1A"),
                Color(hex: "#0F172A"),
                Color(hex: "#111827"),
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ).ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Circular Spinner

private struct SpiceRushCircularSpinner: View {
    let progress: Double
    @State private var rotation: Double = 0
    @State private var counterRotation: Double = 0
    @State private var dashPhase: CGFloat = 0
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.white.opacity(0.06), lineWidth: 12)

            // Base progress ring
            Circle()
                .trim(from: 0, to: max(0.02, min(0.98, progress)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.cyan,
                            Color.indigo,
                            Color.purple,
                            Color.pink,
                        ]),
                        center: .center,
                        angle: .degrees(rotation)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Color.cyan.opacity(0.35), radius: 10)
                .animation(.easeInOut(duration: 0.25), value: progress)

            // Accent dashed arc rotating opposite
            Circle()
                .trim(from: 0.0, to: 0.85)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.2)
                        ]),
                        center: .center,
                        angle: .degrees(counterRotation)
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round, dash: [6, 10], dashPhase: dashPhase)
                )
                .rotationEffect(.degrees(-90))
                .blendMode(.plusLighter)
                .opacity(0.9)

            // Inner pulsing glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.cyan.opacity(0.25), Color.clear]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 120
                    )
                )
                .scaleEffect(pulse ? 1.04 : 0.96)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                counterRotation = -360
            }
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                dashPhase = 40
            }
            pulse = true
        }
    }
}

// MARK: - Previews

#if canImport(SwiftUI)
import SwiftUI
#endif

// Use availability to keep using the modern #Preview API on iOS 17+ and provide a fallback for older versions
@available(iOS 17.0, *)
#Preview("Vertical") {
    SpiceRushLoadingOverlay(progress: 0.2)
}

@available(iOS 17.0, *)
#Preview("Horizontal", traits: .landscapeRight) {
    SpiceRushLoadingOverlay(progress: 0.2)
}

// Fallback previews for iOS < 17
struct SpiceRushLoadingOverlay_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SpiceRushLoadingOverlay(progress: 0.2)
                .previewDisplayName("Vertical (Legacy)")

            SpiceRushLoadingOverlay(progress: 0.2)
                .previewDisplayName("Horizontal (Legacy)")
                .previewLayout(.fixed(width: 812, height: 375)) // Simulate landscape on older previews
        }
    }
}
