//
//  CategorySettingsController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 27.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class CategorySettingsController: UITableViewController {
    
    var type: CategoryType!
    var category: Category? {
        didSet {
            name = category?.name
            icon = category?.icon
            type = category?.type
        }
    }
    
    private let cateogoryRepository = AnyRepository<Category>()
    
    private var preview: CategoryPreviewCell?
    private var iconLabel: UILabel!
    
    private var name: String? = "Name" {
        didSet {
            updateUI()
        }
    }
    private var icon: String! {
        didSet {
            updateUI()
        }
    }
    private let currency = Settings.baseCurrency

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureController()
        configureTableView()
    }
    
}

//MARK: DataSource
extension CategorySettingsController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError("Cannot create section")
        }
        return section.rowsNumber
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(at: indexPath)
    }
}

//MARK: Delegate
extension CategorySettingsController {
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
            case .icon:
                performSegue(withIdentifier: iconPicker, sender: nil)
            }
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension CategorySettingsController: UITextFieldDelegate {
    
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

extension CategorySettingsController: IconPickerDelegate {
    
    func iconPickerController(_ iconPickerController: IconPickerController, didSelectIcon icon: String) {
        self.icon = icon
    }
    
}


//MARK: Segue
extension CategorySettingsController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case iconPicker:
            guard let destination = segue.destination as? IconPickerController else { return }
            destination.delegate = self
        default:
            return
        }
    }
    
}


//MARK: Helpers
extension CategorySettingsController {
    
    private enum Section: Int, CaseIterable {
        case preview
        case settings
        case saving
        
        enum SettingsRow: String, CaseIterable {
            case title = "Title"
            case icon = "Icon"
            
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
                return CategoryPreviewCell.reuseID
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
            case .icon:
                return DetailCell.reuseID
            }
        }
    }
    
    //MARK: Actions
    
    @IBAction private func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc private func save(_ sender: UIButton) {
        if category != nil {
            updateRepository()
        } else {
            create()
        }
    }
    
    private func create() {
        do {
            try cateogoryRepository.insert(object: updateCategory())
            dismiss(animated: true)
        } catch {
            showAlert(error)
        }
    }
    
    private func updateRepository() {
        do {
            try cateogoryRepository.update({ [unowned self] in
                self.updateCategory()
            })
            dismiss(animated: true)
        } catch {
            showAlert(error)
        }
        
    }
    
    private func updateCategory() -> Category {
        let category: Category = self.category == nil ? cateogoryRepository.create() : self.category!
        
        category.type = self.type
        category.name = self.name ?? self.type.defaultName
        category.color = self.type.color
        category.icon = self.icon
        category.currency = self.currency
        
        return category
    }
    
    private func showAlert(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true)
    }
    
    //MARK: Init config
    private func configureTableView() {
        tableView.register(UINib(nibName: CategoryPreviewCell.reuseID, bundle: .main), forCellReuseIdentifier: CategoryPreviewCell.reuseID)
        tableView.register(UINib(nibName: TextFieldCell.reuseID, bundle: .main), forCellReuseIdentifier: TextFieldCell.reuseID)
        tableView.register(UINib(nibName: DetailCell.reuseID, bundle: .main), forCellReuseIdentifier: DetailCell.reuseID)
        tableView.register(UINib(nibName: SaveCell.reuseID, bundle: .main), forCellReuseIdentifier: SaveCell.reuseID)
    }
    private func configureController() {
        title = category?.name ?? title
        if icon == nil {
            icon = type.icon
        }
    }
    
    //MARK: Cell config
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
        guard let previewCell = previewCell as? CategoryPreviewCell else {
            fatalError()
        }
    
        preview = previewCell
        updateUI()
        
        return previewCell
    }
    
    private func configure(settingCell: UITableViewCell, at index: Int) -> UITableViewCell {
        guard let row = Section.SettingsRow(index: index) else {
            fatalError()
        }
        switch row {
        case .icon:
            return configure(iconCell: settingCell)
        case .title:
            return configure(titleCell: settingCell)
        }
    }
    
    private func configure(saveCell: UITableViewCell) -> UITableViewCell {
        guard let saveCell = saveCell as? SaveCell else {
            fatalError()
        }
        
        saveCell.saveButton.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
        return saveCell
    }
    
    private func configure(iconCell: UITableViewCell) -> UITableViewCell {
        guard let iconCell = iconCell as? DetailCell else {
            fatalError()
        }
        
        iconCell.titleLabel.text = Section.SettingsRow.icon.rawValue
        iconCell.disclosure.isHidden = false
        
        iconLabel = iconCell.detailLabel
        updateUI()
        
        return iconCell
    }
    
    private func configure(titleCell: UITableViewCell) -> UITableViewCell {
        guard let titleCell = titleCell as? TextFieldCell else {
            fatalError()
        }
        
        titleCell.titleLabel.text = Section.SettingsRow.title.rawValue
        titleCell.textField.delegate = self
        titleCell.textField.addTarget(self, action: #selector(titleTextFieldDidChangeValue(_:)), for: .editingChanged)
        
        return titleCell
    }
    
    //MARK: Helpers
    private func updateUI() {
        preview?.customContentView.backgroundColor = type?.color
        preview?.iconLabel.text = icon
        preview?.titleLabel.text = name
        
        iconLabel?.text = icon
    }
}
