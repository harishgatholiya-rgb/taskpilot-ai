import Foundation

/// Picks which language to speak/write back in for the handful of places
/// that support Hindi (Siri intents, hourly summary notification). Real
/// localization (String Catalog) would be the long-term answer if this
/// grows past two languages; for now a direct check keeps the Hindi
/// strings simple to read and verify.
enum PreferredLanguage {
    static var isHindi: Bool {
        Locale.preferredLanguages.first?.hasPrefix("hi") ?? false
    }
}
