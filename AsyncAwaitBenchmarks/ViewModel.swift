//
//  ViewModel.swift
//  AsyncAwaitBenchmarks
//
//  Created by Robert Ryan on 9/23/22.
//

import Foundation
import os.log

let poi = OSLog(subsystem: "pi", category: .pointsOfInterest)

@MainActor class ViewModel: ObservableObject {
    @Published var elapsed = ""

    let iterations = 40
    let digits = 9
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    func testSerial() {
        elapsed = "Starting"

        Task.detached { [self] in
            let id = OSSignpostID(log: poi)
            os_signpost(.begin, log: poi, name: #function, signpostID: id)
            let start = Date()

            for i in 0 ..< iterations {
                let pi = calculatePi(iteration: i, decimalPlaces: digits)
                os_signpost(.event, log: poi, name: #function, "%f", pi)
            }

            let end = Date()
            os_signpost(.end, log: poi, name: #function, signpostID: id)

            await MainActor.run {
                elapsed = "Completed serial \(formatter.string(for: end.timeIntervalSince(start))!)"
            }
        }
    }

    func testConcurrentPerform() {
        elapsed = "Starting"

        DispatchQueue.global().async { [self] in
            let id = OSSignpostID(log: poi)
            os_signpost(.begin, log: poi, name: #function, signpostID: id)
            let start = Date()

            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                let pi = calculatePi(iteration: i, decimalPlaces: digits)
                os_signpost(.event, log: poi, name: #function, "%f", pi)
            }

            let end = Date()
            os_signpost(.end, log: poi, name: #function, signpostID: id)

            DispatchQueue.main.async {
                self.elapsed = "Completed concurrent \(self.formatter.string(for: end.timeIntervalSince(start))!)"
            }
        }
    }

    func testAsyncAwait() async {
        let id = OSSignpostID(log: poi)
        os_signpost(.begin, log: poi, name: #function, signpostID: id)
        let start = Date()

        await withTaskGroup(of: Void.self) { group in
            for i in 0 ..< iterations {
                group.addTask { [self] in
                    let pi = calculatePi(iteration: i, decimalPlaces: digits)  // some random, synchronous, computationally intensive calculation
                    os_signpost(.event, log: poi, name: #function, "%f", pi)
                }
            }
            await group.waitForAll()
        }

        let end = Date()
        elapsed = "Completed async-await \(formatter.string(for: end.timeIntervalSince(start))!)"

        os_signpost(.end, log: poi, name: #function, signpostID: id)
    }

    // inefficient Leibniz series to calculate pi

    nonisolated func calculatePi(iteration: Int, decimalPlaces: Int = 9) -> Double {
        let id = OSSignpostID(log: poi)
        os_signpost(.begin, log: poi, name: #function, signpostID: id)

        let threshold = pow(0.1, Double(decimalPlaces)) // (0..<decimalPlaces).reduce(1.0) { value, _ in value / 10.0 }
        var isPositive = true
        var denominator: Double = 1
        var value: Double = 0
        var increment: Double

        repeat {
            increment = 4 / denominator
            if isPositive {
                value += increment
            } else {
                value -= increment
            }
            isPositive.toggle()
            denominator += 2
        } while increment >= threshold

        os_signpost(.end, log: poi, name: #function, signpostID: id, "%f", value)

        return value
    }
}

