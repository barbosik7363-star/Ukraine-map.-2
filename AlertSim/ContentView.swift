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

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                GeometryReader { geo in
                    let canvas = CGRect(origin: .zero, size: geo.size)
                    ZStack {
                        ForEach(regions) { region in
                            if let geometry = UkraineGeometry.shapes[region.id] {
                                let shape = RegionShape(geometry: geometry)
                                shape
                                    .fill(store.level(for: region).mapFill)
                                    .contentShape(shape)
                                    .onTapGesture { selected = region }
                                shape
                                    .stroke(Color.black.opacity(0.45), lineWidth: 0.8)
                                    .allowsHitTesting(false)
                            }
                        }

                        ForEach(regions) { region in
                            if let geometry = UkraineGeometry.shapes[region.id],
                               let label = geometry.label {
                                Text(UkraineGeometry.shortName(region.name))
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.92))
                                    .shadow(color: .black.opacity(0.7), radius: 1)
                                    .position(UkraineGeometry.project(label, in: canvas))
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .padding(.horizontal)

                HStack(spacing: 16) {
                    ForEach(AlertLevel.allCases.filter { $0 != .clear }) { level in
                        HStack(spacing: 6) {
                            Circle().fill(level.mapFill).frame(width: 12, height: 12)
                            Text(level.title).font(.caption)
                        }
                    }
                }
                .padding(.bottom, 8)
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
