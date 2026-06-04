import SwiftUI

struct AppBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            RadialGradient(
                colors: [Color("AppPrimary").opacity(0.12), Color.clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 280
            )
            RadialGradient(
                colors: [Color("AppAccent").opacity(0.08), Color.clear],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 240
            )
            CanvasPatternView()
                .opacity(0.1)
        }
        .ignoresSafeArea()
    }
}

private struct CanvasPatternView: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 28
            var x: CGFloat = 0
            while x < size.width {
                var y: CGFloat = 0
                while y < size.height {
                    let rect = CGRect(x: x, y: y, width: 2, height: 2)
                    context.fill(Path(ellipseIn: rect), with: .color(Color("AppTextSecondary").opacity(0.35)))
                    y += spacing
                }
                x += spacing
            }
        }
    }
}
