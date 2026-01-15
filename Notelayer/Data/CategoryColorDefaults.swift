import Foundation

enum CategoryColorDefaults {
    static func defaultHex(forCategoryId id: String) -> String {
        // Known defaults for built-ins (deterministic, readable)
        switch id {
        case "house": return "#4F8EF7"     // blue
        case "garage": return "#FF8A3D"    // orange
        case "printing": return "#20C997"  // teal
        case "vehicle": return "#9B5DE5"   // purple
        case "tech": return "#2D9CDB"      // sky
        case "finance": return "#2F855A"   // green
        case "shopping": return "#F72585"  // pink
        case "travel": return "#00B4D8"    // cyan
        default:
            // Stable "hashed hue" default (no random)
            let hash = stableHash(id)
            return hsvToHex(h: Double(hash % 360) / 360.0, s: 0.62, v: 0.88)
        }
    }

    static func normalizeHexOrDefault(_ value: String, categoryId: String) -> String {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if isHexColor(cleaned) { return cleaned.hasPrefix("#") ? cleaned : "#\(cleaned)" }
        return defaultHex(forCategoryId: categoryId)
    }

    static func isHexColor(_ s: String) -> Bool {
        let c = s.replacingOccurrences(of: "#", with: "")
        guard c.count == 6 else { return false }
        return Int(c, radix: 16) != nil
    }

    private static func stableHash(_ s: String) -> Int {
        // FNV-1a 32-bit
        var hash: UInt32 = 2166136261
        for b in s.utf8 {
            hash ^= UInt32(b)
            hash = hash &* 16777619
        }
        return Int(hash)
    }

    private static func hsvToHex(h: Double, s: Double, v: Double) -> String {
        let i = Int(h * 6.0)
        let f = h * 6.0 - Double(i)
        let p = v * (1.0 - s)
        let q = v * (1.0 - f * s)
        let t = v * (1.0 - (1.0 - f) * s)
        let (r, g, b): (Double, Double, Double)
        switch i % 6 {
        case 0: (r, g, b) = (v, t, p)
        case 1: (r, g, b) = (q, v, p)
        case 2: (r, g, b) = (p, v, t)
        case 3: (r, g, b) = (p, q, v)
        case 4: (r, g, b) = (t, p, v)
        default: (r, g, b) = (v, p, q)
        }
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

