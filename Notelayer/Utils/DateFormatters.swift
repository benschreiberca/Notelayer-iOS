import Foundation

enum DateFormatters {
    /// Card date format: "Jan 13, 2025" (fixed style)
    static let cardDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "MMM d, yyyy"
        return f
    }()
}

