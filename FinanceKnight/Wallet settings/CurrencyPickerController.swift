//
//  CurrencyPickerController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 27.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

protocol CurrencyPickerDelegate: class  {
    func controller(_ controller: CurrencyPickerController, didSelectCurrency currency: Currency)
}

class CurrencyPickerController: UITableViewController {
    
    weak var delegate: CurrencyPickerDelegate?
    
    private let currencies = CurrencyList.shared.currencies
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: DetailCell.reuseID, bundle: .main), forCellReuseIdentifier: DetailCell.reuseID)
    }

}


//MARK: DataSource

extension CurrencyPickerController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.reuseID, for: indexPath) as! DetailCell
        
        let currency = currencies[indexPath.row]
        cell.titleLabel.text = currency.name
        cell.detailLabel.text = currency.code
        
        return cell
    }
    
}


//MARK: Delegate

extension CurrencyPickerController  {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.controller(self, didSelectCurrency: currencies[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
}
