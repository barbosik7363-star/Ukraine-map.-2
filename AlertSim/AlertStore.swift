import SwiftUI

@MainActor
final class AlertStore: ObservableObject {
    @Published private(set) var levels: [String: AlertLevel] = [:]
    @Published private(set) var log: [LogEntry] = []

    func level(for region: Region) -> AlertLevel {
        levels[region.id] ?? .clear
    }

    var active: [ActiveAlert] {
        regions.compactMap { region in
            let level = level(for: region)
            return level == .clear ? nil : ActiveAlert(region: region, level: level)
        }
        .sorted { $0.level > $1.level }
    }

    func set(_ level: AlertLevel, for region: Region) {
        guard self.level(for: region) != level else { return }
        levels[region.id] = level
        log.insert(LogEntry(date: .now, region: region.name, level: level), at: 0)
        if log.count > 100 { log.removeLast() }
    }

    func setAll(_ level: AlertLevel) {
        regions.forEach { set(level, for: $0) }
    }

    func clearAll() {
        setAll(.clear)
    }

    func simulateRandom() {
        guard let region = regions.randomElement() else { return }
        let level = AlertLevel.allCases.filter { $0 != .clear }.randomElement() ?? .yellow
        set(level, for: region)
    }
}
