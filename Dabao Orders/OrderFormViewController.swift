//
//  OrderFormViewController.swift
//  Dabao Orders
//
//  Created by Nicholas Lim on 26/10/26.
//

import UIKit

protocol OrderFormDelegate: AnyObject {
    func didSave(_ order: Order)
}

class OrderFormViewController: UIViewController {
    weak var delegate: OrderFormDelegate?
    private let order: Order?
    private let dishField = UITextField()
    private let stepper = UIStepper()
    private let quantityLabel = UILabel()
    private let drinkSwitch = UISwitch()

    /// Pass an existing order to edit it, or `nil` to create a new one.
    init(order: Order? = nil) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = order == nil ? "New order" : "Edit order"
        dishField.placeholder = "Dish"
        dishField.borderStyle = .roundedRect
        dishField.text = order?.dish
        stepper.minimumValue = 1
        stepper.value = Double(order?.quantity ?? 1)
        stepper.addAction(
            UIAction { [weak self] _ in self?.updateQuantityLabel() },
            for: .valueChanged
        )
        updateQuantityLabel()
        drinkSwitch.isOn = order?.isDrink ?? false

        let quantityRow = UIStackView(arrangedSubviews: [quantityLabel, stepper])
        quantityRow.axis = .horizontal
        quantityRow.distribution = .equalSpacing

        let drinkLabel = UILabel()
        drinkLabel.text = "Is drink?"
        let drinkRow = UIStackView(arrangedSubviews: [drinkLabel, drinkSwitch])
        drinkRow.axis = .horizontal
        drinkRow.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [dishField, quantityRow, drinkRow])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            stack.leadingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.leadingAnchor
            ),
            stack.trailingAnchor.constraint(
                equalTo: view.layoutMarginsGuide.trailingAnchor
            ),
        ])

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .save,
            primaryAction: UIAction { [weak self] _ in self?.saveTapped() }
        )
    }

    private func updateQuantityLabel() {
        quantityLabel.text = "Quantity: \(Int(stepper.value))"
    }

    private func saveTapped() {
        guard let dish = dishField.text, !dish.isEmpty else { return }
        var result =
            order
            ?? Order(dish: dish, quantity: 1, isDrink: false)
        result.dish = dish
        result.quantity = Int(stepper.value)
        result.isDrink = drinkSwitch.isOn
        delegate?.didSave(result)
        dismiss(animated: true)
    }
}
