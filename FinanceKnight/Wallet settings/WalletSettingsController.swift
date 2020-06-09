//
//  WalletSettingsController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 26.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

class WalletSettingsController: UITableViewController {
    
    var wallet: Category! {
        didSet {
            name = wallet.name
            balance = wallet.balance
            color = wallet.color ?? color
            currency = wallet.currency
            icon = currency?.symbol
            
            tableView.reloadData()
        }
    }
    
    private let categoryRepository = AnyRepository<Category>()
    
    private var preview: WalletPreviewTableCell!
    private var titleTextField: UITextField!
    private var colorView: UIView!
    private var currencyLabel: UILabel!
    
    private var name: String! = "Name" {
        didSet {
            updateUI()
        }
    }
    private var balance: Double = 0.0 {
        didSet {
            updateUI()
        }
    }
    private var color: UIColor = .primary {
        didSet {
            updateUI()
        }
    }
    private var currency: Currency? = Settings.baseCurrency {
        didSet {
            updateUI()
        }
    }
    private var icon: String? = Settings.baseCurrency?.symbol {
        didSet {
            updateUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        title = wallet?.name ?? title
    }
    
}


//MARK: DataSource
extension WalletSettingsController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("Invalid sections number")
        }
        return section.rowsNumber
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(at: indexPath)
    }
    
}

//MARK: Delegate
extension WalletSettingsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        switch section {
        case .settings:
            guard let settingRow = Section.SettingsRow(index: indexPath.row) else { return }
            
            switch settingRow {
            case .title:
                guard let textFieldCell = tableView.cellForRow(at: indexPath) as? TextFieldCell else { return }
                textFieldCell.textField.becomeFirstResponder()
            case .color:
                performSegue(withIdentifier: colorPicker, sender: nil)
            case .currency:
                performSegue(withIdentifier: currencyPicker, sender: nil)
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

extension WalletSettingsController: ColorPickerDelegate {
    
    func controller(_ controller: ColorPickerController, didSelectColor color: UIColor) {
        self.color = color
    }
    
}

extension WalletSettingsController: CurrencyPickerDelegate {
    
    func controller(_ controller: CurrencyPickerController, didSelectCurrency currency: Currency) {
        self.currency = currency
        self.icon = currency.symbol
    }
    
}


//MARK: Segue
extension WalletSettingsController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == colorPicker {
            guard let destination = segue.destination as? ColorPickerController else { return }
            destination.delegate = self
        } else if segue.identifier == currencyPicker {
            guard let destination = segue.destination as? CurrencyPickerController else { return }
            destination.delegate = self
        }
    }
    
}

//MARK: UITextFieldDelegate
extension WalletSettingsController: UITextFieldDelegate {

    @objc func titleTextFieldDidChangeValue(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            name = text
        } else {
            name = textField.placeholder
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

//MARK: Helpers
extension WalletSettingsController {
    
    private enum Section: Int, CaseIterable {
        case preview
        case settings
        case saving
        
        enum SettingsRow: String, CaseIterable {
            case title = "Title"
            case color = "Color"
            case currency = "Currency"
            
            init?(index: Int) {
                guard index < SettingsRow.allCases.count else {
                    return nil
                }
                
                let rawValue = SettingsRow.allCases[index].rawValue
                self.init(rawValue: rawValue)
            }
        }
        
        var rowsNumber: Int {
            switch self {
            case .preview:
                return 1
            case .settings:
                return SettingsRow.allCases.count
            case .saving:
                return 1
            }
        }
        
        func settingRawValue(at index: Int) -> String {
            guard let row = SettingsRow(index: index) else {
                fatalError("Cannot create enum row")
            }
            
            return row.rawValue
        }
        
        func reuseID(at indexPath: IndexPath) -> String {
            switch self {
            case .preview:
                return WalletPreviewTableCell.reuseID
            case .settings:
                return reuseIdForSettings(at: indexPath.row)
            case .saving:
                return SaveCell.reuseID
            }
        }
        
        private func reuseIdForSettings(at index: Int) -> String {
            guard let row = SettingsRow(index: index) else {
                fatalError("Cannot create enum row")
            }
            
            switch row {
            case .title:
                return TextFieldCell.reuseID
            case .color:
                return ColorCell.reuseID
            case .currency:
                return DetailCell.reuseID
            }
        }
    }
    
    
    //MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func save(_ sender: UIButton) {
         if wallet != nil {
            updateRepository()
        } else {
            create()
        }
    }
    
    private func create() {
        do {
            try categoryRepository.insert(object: updateWallet())
            dismiss(animated: true)
        } catch {
            showAlert(error)
        }
    }
    
    private func updateRepository() {
        do {
            try categoryRepository.update({ [unowned self] in
                self.updateWallet()
            })
            dismiss(animated: true)
        } catch {
            showAlert(error)
        }
    }
    
    private func updateWallet() -> Category {
        let wallet: Category = self.wallet == nil ? categoryRepository.create() : self.wallet
        
        wallet.type = .wallet
        wallet.name = name ?? CategoryType.wallet.defaultName
        wallet.currency = currency
        wallet.color = color
        wallet.icon = icon
        
        return wallet
    }

    private func showAlert(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true)
    }
    
    
    //MARK: Configuration method
    private func configureTableView() {
        tableView.register(UINib(nibName: WalletPreviewTableCell.reuseID, bundle: .main), forCellReuseIdentifier: WalletPreviewTableCell.reuseID)
        tableView.register(UINib(nibName: TextFieldCell.reuseID, bundle: .main), forCellReuseIdentifier: TextFieldCell.reuseID)
        tableView.register(UINib(nibName: DetailCell.reuseID, bundle: .main), forCellReuseIdentifier: DetailCell.reuseID)
        tableView.register(UINib(nibName: ColorCell.reuseID, bundle: .main), forCellReuseIdentifier: ColorCell.reuseID)
        tableView.register(UINib(nibName: SaveCell.reuseID, bundle: .main), forCellReuseIdentifier: SaveCell.reuseID)
    }
    
    private func configureCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Cannot create cell")
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: section.reuseID(at: indexPath), for: indexPath)
        
        switch section {
        case .preview:
            return configure(previewCell: cell)
        case .settings:
            return configure(settingCell: cell, at: indexPath.row)
        case .saving:
            return configure(saveCell: cell)
        }
    }
    
    private func configure(previewCell: UITableViewCell) -> UITableViewCell {
        guard let previewCell = previewCell as? WalletPreviewTableCell else {
            fatalError()
        }
        
        preview = previewCell
        updateUI()
        
        return previewCell
    }
    
    private func configure(saveCell: UITableViewCell) -> UITableViewCell {
        guard let saveCell = saveCell as? SaveCell else {
            fatalError()
        }
        
        saveCell.saveButton.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
        return saveCell
    }
    
    private func configure(settingCell: UITableViewCell, at index: Int) -> UITableViewCell {
        guard let row = Section.SettingsRow(index: index) else {
            fatalError()
        }
        switch row {
        case .title:
            return configure(titleCell: settingCell)
        case .color:
            return configure(colorCell: settingCell)
        case .currency:
            return configure(currencyCell: settingCell)
        }
    }
    
    private func configure(titleCell: UITableViewCell) -> UITableViewCell {
        guard let titleCell = titleCell as? TextFieldCell else {
            fatalError()
        }
        
        titleCell.titleLabel.text = Section.SettingsRow.title.rawValue
        
        titleCell.textField.delegate = self
        titleCell.textField.addTarget(self, action: #selector(titleTextFieldDidChangeValue(_:)), for: .editingChanged)
        
        if let name = self.name {
            titleCell.textField.text = name
        }
        
        return titleCell
    }
    
    private func configure(colorCell: UITableViewCell) -> UITableViewCell {
        guard let colorCell = colorCell as? ColorCell else {
            fatalError()
        }
        
        colorCell.titleLabel.text = Section.SettingsRow.color.rawValue
        
        colorView = colorCell.colorView
        colorView.backgroundColor = color
        
        return colorCell
    }
    
    private func configure(currencyCell: UITableViewCell) -> UITableViewCell {
        guard let currencyCell = currencyCell as? DetailCell else {
            fatalError()
        }
        
        currencyCell.titleLabel.text = Section.SettingsRow.currency.rawValue
        currencyCell.disclosure.isHidden = false
        
        currencyLabel = currencyCell.detailLabel
        currencyLabel.text = currency?.code
        
        return currencyCell
    }
    
    private func updateUI() {
        preview?.titleLabel.text = name
        preview?.balanceLabel.text = numberFormatter.string(from: NSNumber(value: balance))
        preview?.currencyLabel.text = icon
        preview?.contentContainer?.backgroundColor = color
        
        colorView?.backgroundColor = color
        currencyLabel?.text = currency?.code
    }
    
}
