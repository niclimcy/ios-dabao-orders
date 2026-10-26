//
//  ViewController.swift
//  Dabao Orders
//
//  Created by Nicholas Lim on 26/10/26.
//

import UIKit

nonisolated enum Section { case drinks, food }

class OrdersViewController: UIViewController, AddOrderDelegate,
    EditOrderDelegate, UITableViewDelegate
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
            primaryAction: UIAction { [weak self] _ in self?.showAdd() }
        )
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Order>()
        snapshot.appendSections([.drinks, .food])

        let grouped = Dictionary(grouping: orders, by: \.isDrink)
        snapshot.appendItems(grouped[true] ?? [], toSection: .drinks)
        snapshot.appendItems(grouped[false] ?? [], toSection: .food)

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func showAdd() {
        let addVC = AddOrderViewController()
        addVC.delegate = self
        present(
            UINavigationController(rootViewController: addVC),
            animated: true
        )
    }

    func didAdd(_ order: Order) {
        orders.append(order)
        save()
        applySnapshot()
    }

    func didEdit(_ order: Order) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else {
            return
        }
        orders[index] = order
        save()
        applySnapshot()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let order = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let editVC = EditOrderViewController(order: order)
        editVC.delegate = self
        present(
            UINavigationController(rootViewController: editVC),
            animated: true
        )
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
