import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AlertsView()
                .tabItem { Label("Тривоги", systemImage: "flag.fill") }
            MapView()
                .tabItem { Label("Мапа", systemImage: "map.fill") }
            InfoView()
                .tabItem { Label("Корисне", systemImage: "info.circle.fill") }
            SettingsView()
                .tabItem { Label("Налаштування", systemImage: "gearshape.fill") }
        }
        .tint(.yellow)
    }
}

struct AlertsView: View {
    @EnvironmentObject var store: AlertStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if store.active.isEmpty {
                        GlassCard {
                            Label("Все тихо", systemImage: "checkmark.seal.fill")
                                .font(.title3.bold())
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    ForEach(store.active) { alert in
                        GlassCard(tint: alert.level.color) {
                            HStack(spacing: 12) {
                                Image(systemName: alert.level.symbol)
                                    .font(.title2)
                                    .foregroundStyle(alert.level.color)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(alert.region.name).font(.headline)
                                    Text(alert.level.title)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }

                    if !store.log.isEmpty {
                        Text("Журнал")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)

                        ForEach(store.log.prefix(30)) { entry in
                            HStack {
                                Circle().fill(entry.level.color).frame(width: 10, height: 10)
                                Text(entry.region).font(.subheadline)
                                Spacer()
                                Text(entry.date, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .glassBackground()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Тривоги")
        }
    }
}

struct MapView: View {
    @EnvironmentObject var store: AlertStore
    @State private var selected: Region?

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 10)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(regions) { region in
                        let level = store.level(for: region)
                        Button {
                            selected = region
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(level.color)
                                    .frame(height: 8)
                                Text(region.name)
                                    .font(.footnote.weight(.semibold))
                                    .multilineTextAlignment(.leading)
                                Text(level.title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 84, alignment: .topLeading)
                            .padding(12)
                            .glassBackground(tint: level == .clear ? nil : level.color)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Мапа")
            .confirmationDialog(
                selected?.name ?? "",
                isPresented: Binding(
                    get: { selected != nil },
                    set: { if !$0 { selected = nil } }
                ),
                titleVisibility: .visible
            ) {
                ForEach(AlertLevel.allCases) { level in
                    Button(level.title) {
                        if let region = selected { store.set(level, for: region) }
                    }
                }
            }
        }
    }
}

struct InfoView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Що означають рівні").font(.headline)
                            Text("Жовта — загроза можлива, слідкуйте за оновленнями.")
                            Text("Червона — є загроза, перейдіть в укриття.")
                            Text("Темно-червона — небезпека висока, залишайтесь в укритті.")
                        }
                        .font(.subheadline)
                    }
                }
                .padding()
            }
            .navigationTitle("Корисне")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: AlertStore
    @State private var pick: AlertLevel = .yellow

    var body: some View {
        NavigationStack {
            Form {
                Section("Симуляція") {
                    Button("Випадкова тривога") { store.simulateRandom() }
                    Picker("Рівень для всіх", selection: $pick) {
                        ForEach(AlertLevel.allCases) { Text($0.title).tag($0) }
                    }
                    Button("Застосувати \(pick.title.lowercased()) до всієї країни") {
                        store.setAll(pick)
                    }
                    Button("Відбій по всій країні", role: .destructive) {
                        store.clearAll()
                    }
                }

                Section("Про застосунок") {
                    Text("Це симулятор для розваги та тестів. Для справжніх сповіщень користуйтесь офіційними джерелами.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Налаштування")
        }
    }
}
