//
//  Created by Artem Novichkov on 09.05.2025.
//

import Foundation
import HealthKit

final class BloodPressureService: MCPServerProtocol {

    enum Error: Swift.Error, LocalizedError {
        case toolNotSupported
        case missingBloodPressureData

        var errorDescription: String? {
            switch self {
            case .toolNotSupported:
                return "Tool not supported"
            case .missingBloodPressureData:
                return "Missing blood pressure data"
            }
        }
    }

    var tools: [Tool] = [
        Tool(name: "blood_pressure",
             toolDescription: "Get the latest blood pressure (systolic and diastolic) from Apple Health.",
             input_schema: ["type": "object"])
    ]

    private lazy var healthStore = HKHealthStore()

    private let systolicType = HKQuantityType(.bloodPressureSystolic)
    private let diastolicType = HKQuantityType(.bloodPressureDiastolic)
    private let bloodPressureType = HKCorrelationType(.bloodPressure)

    func call(_ tool: Tool) async throws -> String {
        guard tool.name == "blood_pressure" else {
            throw Error.toolNotSupported
        }
        let (systolic, diastolic) = try await fetchLatestBloodPressure()
        return "\(Int(systolic))/\(Int(diastolic))"
    }

    private func fetchLatestBloodPressure() async throws -> (systolic: Double, diastolic: Double) {
        try await healthStore.requestAuthorization(toShare: [], read: [systolicType, diastolicType])
        let descriptor = HKSampleQueryDescriptor(predicates: [.sample(type: bloodPressureType)], sortDescriptors: [])
        let samples = try await descriptor.result(for: healthStore)
        guard let sample = samples.first as? HKCorrelation else {
            throw Error.missingBloodPressureData
        }
        guard let systolic = sample.objects(for: systolicType).first as? HKQuantitySample,
              let diastolic = sample.objects(for: diastolicType).first as? HKQuantitySample else {
            throw Error.missingBloodPressureData
        }

        let systolicValue = systolic.quantity.doubleValue(for: .millimeterOfMercury())
        let diastolicValue = diastolic.quantity.doubleValue(for: .millimeterOfMercury())
        return (systolicValue, diastolicValue)
    }
}
