import SwiftUI
import UIKit

// =====================================================================
// IosAiIssues — single-page AI-rule fixture. Everything is on the HOME
// page so one scan of the launch screen catches both AI rules:
//
// 1) image-in-text (WCAG 1.4.5): four images whose pixels contain readable
//    text and which match no exception (not logos, icons, charts, or
//    scanned documents). accessibilityLabels are set deliberately — a label
//    does NOT satisfy this rule, and having labels keeps the missing-label
//    rules quiet so the scan stays focused on the AI findings.
//
// 2) meaningful-reading-order (WCAG 1.3.2/2.4.3): iOS XCUITest dumps
//    preserve accessibilityElements order, so the proven-detectable
//    pattern (ported verbatim from the old app's MeaningfulSequenceView)
//    is the INVERSE of Android's: each card lays its UIKit views out in
//    the CORRECT visual order but overrides container.accessibilityElements
//    to the WRONG order — which is what VoiceOver and the evaluator read.
//    At most one reading-order issue is reported per scan.
// =====================================================================

@main
struct IosAiIssuesApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView { HomeView() }
                .navigationViewStyle(.stack)
        }
    }
}

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("AI Issues")
                    .font(.title2).fontWeight(.bold)

                // ---- image-in-text: 2x2 grid of text-bearing images ----
                HStack(spacing: 8) {
                    Image("hindiEnglishText").resizable().scaledToFit()
                        .accessibilityLabel("Hindi and English mixed script text")
                        .accessibilityIdentifier("ai_text_image_1")
                    Image("textImage2").resizable().scaledToFit()
                        .accessibilityLabel("Promotional banner two")
                        .accessibilityIdentifier("ai_text_image_2")
                }
                .frame(height: 130)
                HStack(spacing: 8) {
                    Image("textImage3").resizable().scaledToFit()
                        .accessibilityLabel("Promotional banner three")
                        .accessibilityIdentifier("ai_text_image_3")
                    Image("japaneseText").resizable().scaledToFit()
                        .accessibilityLabel("Japanese text")
                        .accessibilityIdentifier("ai_text_image_4")
                }
                .frame(height: 130)

                // ---- meaningful-reading-order: correct visuals, wrong a11y order ----
                mroCard("V-01: Price Before Name",
                        "Visual: name → price → action. VoiceOver reads: price → name → action.") {
                    UIKitReadingOrder(elements: [
                        ROElement(kind: .title, text: "Wireless Headphones"),
                        ROElement(kind: .price, text: "$79.99"),
                        ROElement(kind: .button, text: "Add to Cart"),
                    ], readingOrder: [1, 0, 2])
                }
                mroCard("V-02: Input Before Label",
                        "Visual: label → input. VoiceOver reads: input → label.") {
                    UIKitReadingOrder(elements: [
                        ROElement(kind: .label, text: "Email"),
                        ROElement(kind: .input, text: "you@example.com"),
                    ], readingOrder: [1, 0])
                }
                mroCard("V-03: Controls Before Song",
                        "Visual: title → artist → controls. VoiceOver reads: controls → title → artist.") {
                    UIKitReadingOrder(elements: [
                        ROElement(kind: .title, text: "Bohemian Rhapsody"),
                        ROElement(kind: .body, text: "Queen"),
                        ROElement(kind: .button, text: "Previous"),
                        ROElement(kind: .button, text: "Play"),
                        ROElement(kind: .button, text: "Next"),
                    ], readingOrder: [2, 3, 4, 0, 1])
                }
            }
            .padding()
        }
        .navigationTitle("")
    }
}

@ViewBuilder
func mroCard(_ title: String, _ note: String,
             @ViewBuilder content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title).font(.callout).fontWeight(.semibold)
        Text(note).font(.caption)
        content()
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(red: 0.93, green: 0.93, blue: 0.95))
    .cornerRadius(10)
}

// =====================================================================
// Ported from the old app's MeaningfulSequenceView: iOS XCUITest dumps
// preserve accessibilityElements order, so each violation lays its UIKit
// views out in the CORRECT visual order but overrides
// container.accessibilityElements to the WRONG order. Every element sets
// isAccessibilityElement = true and an accessibilityLabel.
// =====================================================================

struct ROElement {
    enum Kind { case title, label, price, body, button, input }
    let kind: Kind
    let text: String
}

struct UIKitReadingOrder: UIViewRepresentable {
    let elements: [ROElement]
    var readingOrder: [Int]? = nil

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.isAccessibilityElement = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        var focusables: [UIView] = []
        for element in elements {
            let view = Self.makeElement(element)
            stack.addArrangedSubview(view)
            focusables.append(view)
        }

        // Violation: force the wrong reading order. (Pass would leave natural order.)
        if let order = readingOrder {
            container.accessibilityElements = order.map { focusables[$0] }
        }
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context: Context) -> CGSize? {
        let width = proposal.width ?? (UIScreen.main.bounds.width - 64)
        let fitted = uiView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: width, height: fitted.height)
    }

    private static func makeElement(_ element: ROElement) -> UIView {
        switch element.kind {
        case .title, .label, .price, .body:
            let label = UILabel()
            label.text = element.text
            label.numberOfLines = 0
            switch element.kind {
            case .title: label.font = .boldSystemFont(ofSize: 17)
            case .price: label.font = .boldSystemFont(ofSize: 20)
            case .body:  label.font = .systemFont(ofSize: 14)
            default:     label.font = .systemFont(ofSize: 15)
            }
            label.isAccessibilityElement = true
            label.accessibilityLabel = element.text
            return label
        case .button:
            let button = UIButton(type: .system)
            button.setTitle(element.text, for: .normal)
            button.contentHorizontalAlignment = .leading
            button.isAccessibilityElement = true
            button.accessibilityLabel = element.text
            button.accessibilityTraits = .button
            return button
        case .input:
            let field = UITextField()
            field.placeholder = element.text
            field.borderStyle = .roundedRect
            field.isAccessibilityElement = true
            field.accessibilityLabel = element.text
            return field
        }
    }
}
