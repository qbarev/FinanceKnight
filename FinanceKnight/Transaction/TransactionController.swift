//
//  TransactionController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 27.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

fileprivate let segmentedControl = "SegmentedControl"

class TransactionController: UITableViewController {

    var transaction: Transaction? {
        didSet {
            self.type = self.transaction?.type ?? type
            self.source = self.transaction?.source
            self.destination = self.transaction?.destination
            self.date = self.transaction?.date ?? Date()
            self.amount = self.transaction?.amount ?? 0.0
            self.comment = self.transaction?.comment
        }
    }
    
    private let transactionRepository = AnyRepository<Transaction>()
    
    private var type: TransactionType = .income
    private var source: Category? = TransactionType.income.defaultSource
    private var destination: Category? = TransactionType.income.defaultDestination
    private var date = Date()
    private var comment: String?
    private var amount: Double = 0.0
    
    private var converterTextField: UITextField!
    private var dateTextField: UITextField!
    private var amountTextField: UITextField!
    private var convertationTextField: UITextField!
    private var currentCategorySender: CategoryPickerCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
    }
}

//MARK: DataSource
extension TransactionController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(index: section) else {
            fatalError("Cannot create section")
        }
        
        if section == .amount {
            if (source?.currency != Settings.baseCurrency || destination?.currency != Settings.baseCurrency) {
                return section.rowsCount
            } else {
                return 1
            }
        }
        
        return section.rowsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(at: indexPath)
    }
    
}

//MARK: Delegate
extension TransactionController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(index: indexPath.section) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        switch section {
        case .categories:
            guard let row = Section.CategoryRow(index: indexPath.row) else {
                return
            }
            currentCategorySender = tableView.cellForRow(at: indexPath) as? CategoryPickerCell
            performSegue(withIdentifier: categoriesPicker, sender: row)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}

extension TransactionController: UITextFieldDelegate {
    
    @objc private func datePickerDidChangeValue(_ sender: UIDatePicker) {
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc private func amountTextFieldDidChangeValue(_ sender: UITextField) {
        guard let amount = amountTextField.number?.doubleValue else { return }
        self.amount = amount
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case _ where textField == amountTextField:
            return textField.availableAdding(string: string)
        default:
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

extension TransactionController: CategoryPickerDelegate {
    
    func categoryPicker(_ categoryPicker: CategoryPickerController, didSelectCategory category: Category) {
        guard let indexPath = tableView.indexPath(for: currentCategorySender) else {
            return
        }
        guard let section = Section(index: indexPath.section), section == .categories else {
            return
        }
        guard let row = Section.CategoryRow(index: indexPath.row) else {
            return
        }
        
        switch row {
        case .source:
            source = category
        case .destination:
            destination = category
        }
        
        currentCategorySender.titleLabel.text = category.name
        currentCategorySender.iconLabel.text = category.icon
        currentCategorySender.colorView.backgroundColor = category.color
        currentCategorySender.detailLabel.text = String(category.balance)
        
        currentCategorySender = nil
        
    }
    
}


//MARK: Segue

extension TransactionController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case categoriesPicker:
            guard let destination = segue.destination as? CategoryPickerController else { return }
            guard let row = sender as? Section.CategoryRow else { return }
            destination.categoryType = chooseCetegoryPickerType(row)
            destination.delegate = self
        default:
            return
        }
    }
    
}


//MARK: Helpers
extension TransactionController {
    
    private enum Section: String, CaseIterable {
        case selection = "Selection"
        case categories = "Categories"
        case amount = "Amount"
        case settings = "Settings"
        case saving = "Save"
        
        enum CategoryRow: String, CaseIterable {
            case source = "Source"
            case destination = "Destination"
            
            var reuseID: String {
                return CategoryPickerCell.reuseID
            }
            
            init?(index: Int) {
                guard index < CategoryRow.allCases.count else {
                    return nil
                }
                let row = CategoryRow.allCases[index]
                self.init(rawValue: row.rawValue)
            }
        }
        
        enum SettingsRow: String, CaseIterable {
            case date = "Date"
            case comment = "Comment"
            
            var reuseID: String {
                return TextFieldCell.reuseID
            }
            
            init?(index: Int) {
                guard index < SettingsRow.allCases.count else {
                    return nil
                }
                let row = SettingsRow.allCases[index]
                self.init(rawValue: row.rawValue)
            }
        }
        
        var rowsCount: Int {
            switch self {
            case .categories:
                return CategoryRow.allCases.count
            case .settings:
                return SettingsRow.allCases.count
            case .amount:
                return 1
            default:
                return 1
            }
        }
        
        init?(index: Int) {
            guard index < Section.allCases.count else {
                return nil
            }
            let section = Section.allCases[index]
            self.init(rawValue: section.rawValue)
        }
        
        func reuseID(at index: Int) -> String? {
            switch self {
            case .selection:
                return segmentedControl
            case .categories:
                return CategoryRow.init(index: index)?.reuseID
            case .amount:
                return DecimalTextFieldCell.reuseID
            case .settings:
                return SettingsRow.init(index: index)?.reuseID
            case .saving:
                return SaveCell.reuseID
            }
        }

    }
    
    
    //MARK: Action
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func selectTransactionType(_ sender: UISegmentedControl) {
        guard let transactionType = TransactionType(rawValue: sender.selectedSegmentIndex) else { return }
        
        if transactionType == self.type {
            return
        } else {
            self.type = transactionType
            self.source = transactionType.defaultSource
            self.destination = transactionType.defaultDestination
            tableView.reloadData()
        }
    }
    
    @objc private func save(_ sender: UIButton) {
        if self.transaction != nil {
            updateRepository()
        } else {
            create()
        }
    }
    
    private func create() {
        do {
            try transactionRepository.insert(object: updateTransaction())
            dismiss(animated: true)
        } catch {
            showAlert(error)
        }
    }
    
    private func updateRepository() {
        do {
            try transactionRepository.update({ [unowned self] in
                self.updateTransaction()
            })
            dismiss(animated: true)
        } catch {
            showAlert(error)
        }
    }
    
    private func updateTransaction() -> Transaction {
        let transaction: Transaction = self.transaction == nil ? transactionRepository.create() : self.transaction!
        
        transaction.type = self.type
        transaction.amount = self.amount
        transaction.date = self.date
        transaction.comment = self.comment
        
        transaction.source = self.source
        transaction.destination = self.destination
        
        return transaction
    }
    
    private func showAlert(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    //MARK: Init configuration
    private func configureTableView() {
        tableView.register(UINib(nibName: CategoryPickerCell.reuseID, bundle: .main), forCellReuseIdentifier: CategoryPickerCell.reuseID)
        tableView.register(UINib(nibName: TextFieldCell.reuseID, bundle: .main), forCellReuseIdentifier: TextFieldCell.reuseID)
        tableView.register(UINib(nibName: DecimalTextFieldCell.reuseID, bundle: .main), forCellReuseIdentifier: DecimalTextFieldCell.reuseID)
        tableView.register(UINib(nibName: SaveCell.reuseID, bundle: .main), forCellReuseIdentifier: SaveCell.reuseID)
    }
    
    //MARK: Cell configuration
    private func configureCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(index: indexPath.section) else {
            fatalError()
        }
        guard let reuseID = section.reuseID(at: indexPath.row) else {
            fatalError()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        switch section {
        case .selection:
            return cell
        case .categories:
            return configure(categoryCell: cell, at: indexPath.row)
        case .amount:
            return configure(amountCell: cell)
        case .settings:
            return configure(settingCell: cell, at: indexPath.row)
        case .saving:
            return configure(saveCell: cell)
        }
    }
    
    private func configure(segmentedCell: UITableViewCell) -> UITableViewCell {
        guard let segmentedCell = segmentedCell as? SegmentedCell else {
            fatalError()
        }
        if self.transaction != nil {
            segmentedCell.segmentedControl.isHidden = true
        }
        return segmentedCell
    }
    
    private func configure(categoryCell: UITableViewCell, at row: Int) -> UITableViewCell {
        guard let categoryRow = Section.CategoryRow(index: row) else {
            fatalError()
        }
        
        switch categoryRow {
        case .source:
            return configure(sourceCell: categoryCell)
        case .destination:
            return configure(destinationCell: categoryCell)
        }
    }
    
    private func configure(amountCell: UITableViewCell) -> UITableViewCell {
        guard let amountCell = amountCell as? DecimalTextFieldCell else {
            fatalError()
        }
        amountCell.titleLabel.text = Section.amount.rawValue
        if amount != 0.0 {
            amountCell.textField.text = String(amount)
        }
        amountCell.textField.delegate = self
        amountTextField = amountCell.textField
        amountTextField.addTarget(self, action: #selector(amountTextFieldDidChangeValue(_:)), for: .editingChanged)
        
        return amountCell
    }
    
    private func configure(settingCell: UITableViewCell, at row: Int) -> UITableViewCell {
        guard let settingRow = Section.SettingsRow(index: row) else {
            fatalError()
        }
        
        switch settingRow {
        case .date:
            return configure(dateCell: settingCell)
        case .comment:
            return configure(commentCell: settingCell)
        }
    }
    
    private func configure(saveCell: UITableViewCell) -> UITableViewCell {
        guard let saveCell = saveCell as? SaveCell else {
            fatalError()
        }
        saveCell.saveButton.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
        return saveCell
    }
    
    //MARK: Rows config
    private func configure(sourceCell: UITableViewCell) -> UITableViewCell {
        guard let sourceCell = sourceCell as? CategoryPickerCell else {
            fatalError()
        }
        
        sourceCell.configure(source)
        sourceCell.disclosure.isHidden = false
        
        return sourceCell
    }
    
    private func configure(destinationCell: UITableViewCell) -> UITableViewCell {
        guard let destinationCell = destinationCell as? CategoryPickerCell else {
            fatalError()
        }
        
        destinationCell.configure(destination)
        destinationCell.disclosure.isHidden = false
        
        return destinationCell
    }
    
    private func configure(dateCell: UITableViewCell) -> UITableViewCell {
        guard let dateCell = dateCell as? TextFieldCell else {
            fatalError()
        }
    
        dateCell.titleLabel.text = Section.SettingsRow.date.rawValue
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerDidChangeValue(_:)), for: .valueChanged)
        
        dateCell.textField.inputView = datePicker
        dateCell.textField.text = dateFormatter.string(from: self.date)
        dateCell.textField.doneAccessory = true
        dateTextField = dateCell.textField
        
        return dateCell
    }
    
    private func configure(commentCell: UITableViewCell) -> UITableViewCell {
        guard let commentCell = commentCell as? TextFieldCell else {
            fatalError()
        }
        
        commentCell.titleLabel.text = Section.SettingsRow.comment.rawValue
        
        commentCell.textField.text = self.comment
        commentCell.textField.delegate = self
        
        return commentCell
    }
    
    //MARK: SegueHelper
    
    private func chooseCetegoryPickerType(_ row: Section.CategoryRow) -> CategoryType? {
        switch row {
        case .source where type == .income:
            return .income
        case .source where type == .expense:
            return .wallet
        case .destination where type == .income:
            return .wallet
        case .destination where type == .expense:
            return .expense
        case _ where type == .transfer:
            return .wallet
            
        default:
            return nil
        }
    }
    
}
