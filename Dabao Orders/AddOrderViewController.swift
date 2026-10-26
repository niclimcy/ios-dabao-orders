//
//  AddOrderDelegate.swift
//  Dabao Orders
//
//  Created by Nicholas Lim on 26/10/26.
//

import UIKit

protocol AddOrderDelegate: AnyObject {
    func didAdd(_ order: Order)
}

class AddOrderViewController: UIViewController {
    weak var delegate: AddOrderDelegate?
    private let dishField = UITextField()
    private let stepper = UIStepper()
    private let drinkSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New order"
        dishField.placeholder = "Dish"
        dishField.borderStyle = .roundedRect
        stepper.minimumValue = 1
        stepper.value = 1

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

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .save,
            primaryAction: UIAction { [weak self] _ in self?.saveTapped() }
        )
    }

    private func saveTapped() {
        guard let dish = dishField.text, !dish.isEmpty else { return }
        delegate?.didAdd(
            Order(
                dish: dish,
                quantity: Int(stepper.value),
                isDrink: drinkSwitch.isOn
            )
        )
        dismiss(animated: true)
    }
}
