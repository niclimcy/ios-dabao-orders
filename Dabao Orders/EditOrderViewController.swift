//
//  EditOrderViewController.swift
//  Dabao Orders
//
//  Created by Nicholas Lim on 26/10/26.
//

import UIKit

protocol EditOrderDelegate: AnyObject {
    func didEdit(_ order: Order)
}

class EditOrderViewController: UIViewController {
    weak var delegate: EditOrderDelegate?
    private let order: Order
    private let dishField = UITextField()
    private let stepper = UIStepper()
    private let drinkSwitch = UISwitch()

    init(order: Order) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Edit order"
        dishField.placeholder = "Dish"
        dishField.borderStyle = .roundedRect
        dishField.text = order.dish
        stepper.minimumValue = 1
        stepper.value = Double(order.quantity)
        drinkSwitch.isOn = order.isDrink

        let drinkLabel = UILabel()
        drinkLabel.text = "Is drink?"
        let drinkRow = UIStackView(arrangedSubviews: [drinkLabel, drinkSwitch])
        drinkRow.axis = .horizontal
        drinkRow.distribution = .equalSpacing

        let stack = UIStackView(arrangedSubviews: [dishField, stepper, drinkRow])
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

    private func saveTapped() {
        guard let dish = dishField.text, !dish.isEmpty else { return }
        var updated = order
        updated.dish = dish
        updated.quantity = Int(stepper.value)
        updated.isDrink = drinkSwitch.isOn
        delegate?.didEdit(updated)
        dismiss(animated: true)
    }
}
