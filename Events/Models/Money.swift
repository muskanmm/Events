//
//  Money.swift
//  Formats cents as a USD string
//

import Foundation

enum Money {
    static func format(_ cents: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: Double(cents) / 100)) ?? "$0"
    }
}
