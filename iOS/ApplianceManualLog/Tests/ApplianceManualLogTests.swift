import XCTest
@testable import ApplianceManualLog

@MainActor
final class StoreTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.isPro = false
    }

    func testAddItem() {
        let item = ApplianceManualLogItem(appliance: "A", modelNumber: "B", serialNumber: "C")
        let added = store.add(item)
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<Store.freeLimit {
            store.add(ApplianceManualLogItem(appliance: "\(i)", modelNumber: "B", serialNumber: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        let blocked = store.add(ApplianceManualLogItem(appliance: "over", modelNumber: "B", serialNumber: "C"))
        XCTAssertFalse(blocked)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(ApplianceManualLogItem(appliance: "\(i)", modelNumber: "B", serialNumber: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    func testDeleteItem() {
        let item = ApplianceManualLogItem(appliance: "A", modelNumber: "B", serialNumber: "C")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateItem() {
        var item = ApplianceManualLogItem(appliance: "A", modelNumber: "B", serialNumber: "C")
        store.add(item)
        item.appliance = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.appliance, "Updated")
    }

    func testCanAddMoreTrueInitially() {
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsets() {
        store.add(ApplianceManualLogItem(appliance: "A", modelNumber: "B", serialNumber: "C"))
        store.add(ApplianceManualLogItem(appliance: "D", modelNumber: "E", serialNumber: "F"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testPersistenceRoundTrip() {
        store.add(ApplianceManualLogItem(appliance: "Persist", modelNumber: "B", serialNumber: "C"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.appliance == "Persist" }))
    }
}
