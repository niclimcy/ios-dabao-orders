//
//  OrderDataSource.swift
//  Dabao Orders
//
//  Created by Nicholas Lim on 26/10/26.
//

import UIKit

class OrdersDataSource: UITableViewDiffableDataSource<Section, Order> {
    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch snapshot().sectionIdentifiers[section] {
        case .drinks: return "Drinks"
        case .food: return "Food"
        }
    }
}
