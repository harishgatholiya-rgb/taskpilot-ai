import Foundation

/// Picks which language App Intents should speak back in. Real
/// localization (String Catalog) would be the long-term answer if this
/// grows past two languages; for now a direct check keeps the Hindi
/// responses simple to read and verify.
enum PreferredLanguage {
    static var isHindi: Bool {
        Locale.preferredLanguages.first?.hasPrefix("hi") ?? false
    }
}
