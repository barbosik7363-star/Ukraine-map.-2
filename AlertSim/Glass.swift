import SwiftUI

struct GlassBackground: ViewModifier {
    var tint: Color?

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        if #available(iOS 26.0, *) {
            let glass: Glass = tint.map { Glass.regular.tint($0.opacity(0.45)) } ?? .regular
            content.glassEffect(glass, in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(.white.opacity(0.15)))
        }
    }
}

extension View {
    func glassBackground(tint: Color? = nil) -> some View {
        modifier(GlassBackground(tint: tint))
    }
}

struct GlassCard<Content: View>: View {
    var tint: Color? = nil
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground(tint: tint)
    }
}
