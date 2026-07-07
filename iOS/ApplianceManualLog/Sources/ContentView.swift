import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingItem: ApplianceManualLogItem?

    var body: some View {
        Group {

        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.items) { item in
                            row(for: item)
                                .listRowBackground(Theme.background)
                                .contentShape(Rectangle())
                                .onTapGesture { editingItem = item }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .navigationTitle("Appliance Manual Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                    .foregroundColor(Theme.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                    .foregroundColor(Theme.accent)
                }
            }
            .sheet(isPresented: $showingAdd) {
                EditItemView(item: nil)
            }
            .sheet(item: $editingItem) { item in
                EditItemView(item: item)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)

        }

    }

    private func row(for item: ApplianceManualLogItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.appliance)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text(item.modelNumber)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
            Text(item.serialNumber)
                .font(Theme.captionFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(Theme.accent)
            Text("No Appliances yet")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text("Tap + to add your first one.")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
        }
    }

}

struct EditItemView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    var item: ApplianceManualLogItem?

    @State private var appliance: String = ""
    @State private var modelNumber: String = ""
    @State private var serialNumber: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Appliance") {
                    TextField("Appliance", text: $appliance)
                        .accessibilityIdentifier("fieldAppliance")
                }
                Section("Model Number") {
                    TextField("Model Number", text: $modelNumber)
                        .accessibilityIdentifier("fieldModelNumber")
                }
                Section("Serial Number") {
                    TextField("Serial Number", text: $serialNumber)
                        .accessibilityIdentifier("fieldSerialNumber")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .navigationTitle(item == nil ? "Add Appliance" : "Edit Appliance")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveButton")
                    .disabled(appliance.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item {
                    appliance = item.appliance
                    modelNumber = item.modelNumber
                    serialNumber = item.serialNumber
                }
            }
        }
    }

    private func save() {
        if var existing = item {
            existing.appliance = appliance
            existing.modelNumber = modelNumber
            existing.serialNumber = serialNumber
            store.update(existing)
        } else {
            let newItem = ApplianceManualLogItem(appliance: appliance, modelNumber: modelNumber, serialNumber: serialNumber)
            store.add(newItem)
        }
        dismiss()
    }
}
