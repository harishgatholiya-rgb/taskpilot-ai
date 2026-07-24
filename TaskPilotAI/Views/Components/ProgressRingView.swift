import SwiftUI

/// Circular progress indicator used on the Dashboard for "today's progress".
struct ProgressRingView: View {
    /// 0...1
    let progress: Double
    var lineWidth: CGFloat = 10
    var diameter: CGFloat = 88

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.15), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    AngularGradient(
                        colors: [.accentColor.opacity(0.6), .accentColor],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: clampedProgress)

            Text(clampedProgress, format: .percent.precision(.fractionLength(0)))
                .font(.system(.callout, design: .rounded, weight: .bold))
                .contentTransition(.numericText())
        }
        .frame(width: diameter, height: diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today's progress")
        .accessibilityValue(clampedProgress.formatted(.percent.precision(.fractionLength(0))))
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.xl) {
        ProgressRingView(progress: 0.0)
        ProgressRingView(progress: 0.4)
        ProgressRingView(progress: 1.0)
    }
    .padding()
}
