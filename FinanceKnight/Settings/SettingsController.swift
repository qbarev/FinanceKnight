//
//  SettingsController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 05.06.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
}

//MARK: DataSource
extension SettingsController {
 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       SettingsDataSource.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(at: indexPath)
    }
    
}

//MARK: Delegate
extension SettingsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = SettingsDataSource.allCases[indexPath.row]
        switch row {
        case .baseCurrency:
            performSegue(withIdentifier: currencyPicker, sender: nil)
        }
    }
    
}

//MARK: CurrencyPickerDelegate
extension SettingsController: CurrencyPickerDelegate {
    
    func controller(_ controller: CurrencyPickerController, didSelectCurrency currency: Currency) {
        Settings.baseCurrency = currency
        tableView.reloadData()
    }
    
}

//MARK: Segue
extension SettingsController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case currencyPicker:
            guard let destination = segue.destination as? CurrencyPickerController else { return }
            destination.delegate = self
        default:
            return
        }
    }
    
}

//MARK: Helpers
extension SettingsController {
    
    private enum SettingsDataSource: String, CaseIterable {
        case baseCurrency = "Base currency"
        
        var reuseID: String {
            switch self {
            case .baseCurrency:
                return DetailCell.reuseID
            }
        }
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: DetailCell.reuseID, bundle: .main), forCellReuseIdentifier: DetailCell.reuseID)
    }
    
    //MARK: Cell configuration
    private func configureCell(at indexPath: IndexPath) -> UITableViewCell {
        let section = SettingsDataSource.allCases[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: section.reuseID, for: indexPath)
        
        switch section {
        case .baseCurrency:
            return configure(settingCell: cell)
        }
    }
    
    private func configure(settingCell: UITableViewCell) -> UITableViewCell {
        guard let settingCell = settingCell as? DetailCell else {
            fatalError()
        }
        settingCell.titleLabel.text = SettingsDataSource.baseCurrency.rawValue
        settingCell.detailLabel.text = Settings.baseCurrency?.code
        
        return settingCell
    }
    
}


