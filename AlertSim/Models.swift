import SwiftUI

enum AlertLevel: Int, CaseIterable, Identifiable, Comparable {
    case clear = 0, yellow, red, darkRed

    var id: Int { rawValue }

    static func < (lhs: AlertLevel, rhs: AlertLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var title: String {
        switch self {
        case .clear: return "Відбій"
        case .yellow: return "Жовта"
        case .red: return "Червона"
        case .darkRed: return "Темно-червона"
        }
    }

    var color: Color {
        switch self {
        case .clear: return .gray
        case .yellow: return .yellow
        case .red: return Color(red: 1.0, green: 0.27, blue: 0.23)
        case .darkRed: return Color(red: 0.55, green: 0.0, blue: 0.05)
        }
    }

    var symbol: String {
        self == .clear ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }
}

struct Region: Identifiable, Hashable {
    let id: String
    let name: String
    init(_ name: String) {
        self.id = name
        self.name = name
    }
}

let regions: [Region] = [
    "м. Київ", "Київська", "Чернігівська", "Сумська", "Харківська",
    "Луганська", "Донецька", "Запорізька", "Херсонська",
    "Автономна Республіка Крим", "м. Севастополь", "Одеська",
    "Миколаївська", "Дніпропетровська", "Кіровоградська", "Полтавська",
    "Черкаська", "Вінницька", "Житомирська", "Хмельницька",
    "Тернопільська", "Рівненська", "Волинська", "Львівська",
    "Закарпатська", "Івано-Франківська", "Чернівецька"
].map(Region.init)

struct ActiveAlert: Identifiable {
    let region: Region
    let level: AlertLevel
    var id: String { region.id }
}

struct LogEntry: Identifiable {
    let id = UUID()
    let date: Date
    let region: String
    let level: AlertLevel
}
