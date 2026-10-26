//
//  Order.swift
//  Dabao Orders
//
//  Created by Nicholas Lim on 26/10/26.
//

import Foundation

nonisolated struct Order: Hashable, Codable {
    var id = UUID()
    var dish: String
    var quantity: Int
    var isDrink: Bool
}
