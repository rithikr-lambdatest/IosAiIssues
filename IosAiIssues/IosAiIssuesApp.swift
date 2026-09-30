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
// 2) meaningful-reading-order (WCAG 1.3.2/2.4.3): three numbered steps
//    stacked vertically inside a UIKit container whose accessibilityElements
//    is deliberately mis-ordered (Step 1 -> Step 3 -> Step 2) — the
//    strongest traversal override on iOS. A cross-row scramble of
//    explicitly numbered content breaks logical flow and matches none of
//    the engine's intentional cases. At most one reading-order issue is
//    reported per scan.
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
                    Image("textImage1").resizable().scaledToFit()
                        .accessibilityLabel("Promotional banner one")
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
                    Image("textImage4").resizable().scaledToFit()
                        .accessibilityLabel("Promotional banner four")
                        .accessibilityIdentifier("ai_text_image_4")
                }
                .frame(height: 130)

                // ---- meaningful-reading-order: scrambled numbered steps ----
                Text("How to order")
                    .font(.headline)
                ScrambledStepsView()
                    .frame(height: 150)
                    .accessibilityIdentifier("ai_reading_order_block")
            }
            .padding()
        }
        .navigationTitle("")
    }
}

/// Three visually stacked steps whose accessibilityElements order is
/// deliberately wrong: Step 1 -> Step 3 -> Step 2.
struct ScrambledStepsView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIStackView {
        func step(_ text: String, id: String) -> UILabel {
            let label = UILabel()
            label.text = text
            label.accessibilityIdentifier = id
            label.font = .preferredFont(forTextStyle: .body)
            label.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.97, alpha: 1)
            return label
        }
        let step1 = step("Step 1: Choose your product", id: "ai_step1")
        let step2 = step("Step 2: Add to cart", id: "ai_step2")
        let step3 = step("Step 3: Checkout", id: "ai_step3")

        let stack = UIStackView(arrangedSubviews: [step1, step2, step3])
        stack.axis = .vertical
        stack.spacing = 8
        // Visual order is 1, 2, 3 — traversal order is forced to 1, 3, 2.
        stack.accessibilityElements = [step1, step3, step2]
        return stack
    }
    func updateUIView(_ uiView: UIStackView, context: Context) {}
}
