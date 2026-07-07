import Foundation

struct ApplianceManualLogItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var appliance: String
    var modelNumber: String
    var serialNumber: String
    var createdAt: Date = Date()
}
