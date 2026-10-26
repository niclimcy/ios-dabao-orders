//
//  ViewController.swift
//  Dabao Orders
//
//  Created by Nicholas Lim on 26/10/26.
//

import UIKit

nonisolated enum Section { case drinks, food }

class OrdersViewController: UIViewController, OrderFormDelegate,
    UITableViewDelegate
{
    private let tableView = UITableView()

    private var orders: [Order] = [
        Order(dish: "Chicken rice", quantity: 1, isDrink: false),
        Order(dish: "Teh peng", quantity: 2, isDrink: true),
        Order(dish: "Roti prata", quantity: 3, isDrink: false),
    ]

    private var dataSource: OrdersDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Orders"
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self

        dataSource = OrdersDataSource(tableView: tableView) {
            tableView,
            indexPath,
            order in
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "cell",
                for: indexPath
            )
            var content = cell.defaultContentConfiguration()
            content.text = order.dish
            content.secondaryText = "x\(order.quantity)"
            cell.contentConfiguration = content
            return cell
        }

        load()
        applySnapshot()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in self?.showForm() }
        )
    }

    private func applySnapshot(reconfiguring changed: [Order] = []) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Order>()
        snapshot.appendSections([.drinks, .food])

        let grouped = Dictionary(grouping: orders, by: \.isDrink)
        snapshot.appendItems(grouped[true] ?? [], toSection: .drinks)
        snapshot.appendItems(grouped[false] ?? [], toSection: .food)

        snapshot.reconfigureItems(changed)
        dataSource.apply(snapshot, animatingDifferences: true)
    }


    private func showForm(for order: Order? = nil) {
        let formVC = OrderFormViewController(order: order)
        formVC.delegate = self
        present(
            UINavigationController(rootViewController: formVC),
            animated: true
        )
    }

    func didSave(_ order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            orders[index] = order
            save()
            applySnapshot(reconfiguring: [order])
        } else {
            orders.append(order)
            save()
            applySnapshot()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let order = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        showForm(for: order)
    }

    private let fileURL = URL.documentsDirectory.appending(path: "orders.json")

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(orders)
            try data.write(to: fileURL)
        } catch {
            print("Save failed: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
            let saved = try? JSONDecoder().decode([Order].self, from: data)
        else { return }
        orders = saved
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let order = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        let delete = UIContextualAction(style: .destructive, title: "Delete") {
            [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            self.orders = self.orders.filter { $0.id != order.id }
            self.save()
            self.applySnapshot()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

#Preview {
    UINavigationController(rootViewController: OrdersViewController())
}
