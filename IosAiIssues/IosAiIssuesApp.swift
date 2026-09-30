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
// 2) meaningful-reading-order (WCAG 1.3.2/2.4.3): the violation lives in
//    the VISUAL order itself (proven-detectable pattern, mirroring the
//    Meaningful Sequence demo screen): price rendered above the product
//    name, input above its label, playback controls above the song they
//    control. No traversal overrides. At most one reading-order issue is
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

                // ---- meaningful-reading-order: visually wrong semantic order ----
                mroCard("V-01: Price Before Name", "Price rendered ABOVE the product name.") {
                    Text("$79.99").font(.title).fontWeight(.bold)
                        .accessibilityIdentifier("ai_mro_price")
                    Text("Wireless Headphones").font(.subheadline)
                        .accessibilityIdentifier("ai_mro_product")
                }
                mroCard("V-02: Input Before Label", "Text field rendered ABOVE its label.") {
                    TextField("Enter here...", text: .constant(""))
                        .textFieldStyle(.roundedBorder)
                        .accessibilityIdentifier("ai_mro_email_input")
                    Text("Email").font(.subheadline)
                        .accessibilityIdentifier("ai_mro_email_label")
                }
                mroCard("V-03: Controls Before Song", "Playback controls rendered ABOVE the song title/artist.") {
                    HStack(spacing: 8) {
                        Button("Prev") {}.buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("ai_mro_prev")
                        Button("Play") {}.buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("ai_mro_play")
                        Button("Next") {}.buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("ai_mro_next")
                    }
                    Text("Bohemian Rhapsody").font(.headline)
                        .accessibilityIdentifier("ai_mro_song")
                    Text("Queen").font(.subheadline)
                        .accessibilityIdentifier("ai_mro_artist")
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
