import Foundation

public enum CoreDateFormatters {
    /// Card date format: "Jan 13, 2025" (fixed style)
    public static let cardDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        f.dateFormat = "MMM d, yyyy"
        return f
    }()
}
