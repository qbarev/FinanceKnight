//
//  WalletOverviewController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 28.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryOverviewController: UITableViewController {
    
    var category: Category!
    
    private let transactionRepository = AnyRepository<Transaction>()
    private let categoryRepository = AnyRepository<Category>()
    private var converter: Converter!
    
    private var type: CategoryType? {
        category?.type
    }
    
    private var transactions: [Transaction] {
        var transactions = [Transaction]()
        
        if let incomings = category?.incomings {
            transactions.append(contentsOf: incomings)
        }
        if let outcomings = category?.outcomings {
             transactions.append(contentsOf: outcomings)
        }
        
        return transactions
    }
    
    private var preview: UITableViewCell!
    private var token: StorageNotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureController()
        configureTableView()
        observeRepository()
    }
    
    deinit {
        tokenInvalidate()
    }

}

//MARK: DataSource
extension CategoryOverviewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            fatalError()
        }
        
        switch section {
        case .preview:
            return 1
        case .transactions:
            return transactions.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(at: indexPath)
    }
}

//MARK: Delegate {
extension CategoryOverviewController {
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let section = Section(index: indexPath.section), section != .preview else { return .none }
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            deleteTransaction(at: indexPath)
        default:
            return
        }
    }
    
}

//MARK: Segue
extension CategoryOverviewController  {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case walletSettings:
            guard let destinationNC = segue.destination as? UINavigationController else { return }
            guard let destination = destinationNC.viewControllers.first as? WalletSettingsController else { return }
            destination.wallet = category
        case categorySettings:
            guard let destinationNC = segue.destination as? UINavigationController else { return }
            guard let destination = destinationNC.viewControllers.first as? CategorySettingsController else { return }
            destination.category = category
        default:
            return
        }
    }
    
}

//MARK: Helpers
extension CategoryOverviewController {
    
    private enum Section: Int, CaseIterable {
        case preview
        case transactions
        
        init?(index: Int) {
            switch index {
            case Section.preview.rawValue:
                self.init(rawValue: index)
            default:
                self.init(rawValue: Section.transactions.rawValue)
            }
        }
        
        func reuseID(type: CategoryType) -> String {
            switch self {
            case .preview:
                return previewReuseID(type: type)
            case .transactions:
                return TransactionCell.reuseID
            }
        }
        
        private func previewReuseID(type: CategoryType) -> String {
            switch type {
            case .wallet:
                return WalletPreviewTableCell.reuseID
            default:
                return CategoryPreviewCell.reuseID
            }
        }

    }
    
    //MARK: Сonfig
    private func configureTableView() {
        tableView.register(UINib(nibName: CategoryPreviewCell.reuseID, bundle: .main), forCellReuseIdentifier: CategoryPreviewCell.reuseID)
        tableView.register(UINib(nibName: WalletPreviewTableCell.reuseID, bundle: .main), forCellReuseIdentifier: WalletPreviewTableCell.reuseID)
        tableView.register(UINib(nibName: TransactionCell.reuseID, bundle: .main), forCellReuseIdentifier: TransactionCell.reuseID)
    }
    
    private func observeRepository() {
        token = transactionRepository.observeStorage(notification: .didChange, completion: { changes in
            self.tableView.reloadData()
        })
    }
    
    private func tokenInvalidate() {
        token.invalidate()
    }
    
    private func configureController() {
        title = category?.name
        addBarButtonsItems()
    }
    
    private func addBarButtonsItems() {
        let editButton = UIButton()
        editButton.setImage(#imageLiteral(resourceName: "editButton"), for: .normal)
        editButton.setImage(#imageLiteral(resourceName: "SelectedEditButton"), for: .highlighted)
        editButton.addTarget(self, action: #selector(editCategory(_:)), for: .touchUpInside)
        let editBarButton = UIBarButtonItem(customView: editButton)
        
        let deleteButton = UIButton()
        deleteButton.setImage(#imageLiteral(resourceName: "RemoveButton"), for: .normal)
        deleteButton.setImage(#imageLiteral(resourceName: "SelectedRemoveButton"), for: .highlighted)
        deleteButton.addTarget(self, action: #selector(deleteCategory(_:)), for: .touchUpInside)
        let deleteBarButton = UIBarButtonItem(customView: deleteButton)
        
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 20
        
        navigationItem.rightBarButtonItems = [deleteBarButton, space, editBarButton]
    }
    
    //MARK: Actions
    @objc private func editCategory(_ sender: UIBarButtonItem) {
        switch type {
        case .wallet:
            performSegue(withIdentifier: walletSettings, sender: nil)
        default:
            performSegue(withIdentifier: categorySettings, sender: nil)
        }
    }
    
    @objc private func deleteCategory(_ sender: UIBarButtonItem) {
        guard category != nil else { return }
        showDeletionAlert()
    }
    
    private func showDeletionAlert() {
        let alertController = UIAlertController(title: "Delete \(category!.name)?", message: "Please accept deletion.", preferredStyle: .alert)
        let accept = UIAlertAction(title: "OK", style: .destructive, handler: { [unowned self] _ in
            try! self.categoryRepository.delete(object: self.category)
            self.tokenInvalidate()
            self.navigationController?.popViewController(animated: true)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(accept)
        alertController.addAction(cancel)
        
        present(alertController, animated: true)
    }
    
    //MARK: Cells config
    private func configureCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(index: indexPath.section) else {
            fatalError()
        }
        guard let type = self.type else {
            fatalError()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: section.reuseID(type: type), for: indexPath)
        
        switch section {
        case .preview:
            return configure(previewCell: cell)
        case .transactions:
            return configure(transactionCell: cell, at: indexPath.row)
        }
    }
    
    private func configure(previewCell: UITableViewCell) -> UITableViewCell {
        preview = previewCell
        updatePreviewCell()
        return preview
    }
    
    private func configure(transactionCell: UITableViewCell, at index: Int) -> UITableViewCell {
        guard let transactionCell = transactionCell as? TransactionCell else {
            fatalError()
        }
        let transaction = transactions[index]
        transactionCell.configureWithTransaction(transaction)
        
        if transaction.currency != category.currency {
            let converter = Converter(base: transaction.currency!, quote: category.currency!)
            transactionCell.activityIndicatior.startAnimating()
            transactionCell.titleStack.isHidden = true
            transactionCell.amountStack.isHidden = true
            converter.convert(amount: transaction.amount, completion: { result in
                if let amount = result[converter.quote.code] {
                    let amountString = numberFormatter.string(from: NSNumber(value: amount)) ?? "0"
                    let currencyString = converter.quote.symbol
                    DispatchQueue.main.async {
                        transactionCell.activityIndicatior.stopAnimating()
                        transactionCell.titleStack.isHidden = false
                        transactionCell.amountStack.isHidden = false
                        transactionCell.detailLabel.text = currencyString + " " + amountString
                    }
                }
            }, failed: {
                DispatchQueue.main.async {
                    transactionCell.activityIndicatior.stopAnimating()
                    transactionCell.titleStack.isHidden = false
                    transactionCell.amountStack.isHidden = false
                }
            })
        }
        return transactionCell
    }
    
    private func updatePreviewCell() {
        if let walletPreview = self.preview as? WalletPreviewTableCell {
            walletPreview.titleLabel.text = category?.name
            walletPreview.balanceLabel.text = numberFormatter.string(from: NSNumber(value: category?.balance ?? 0))
            walletPreview.contentContainer?.backgroundColor = category?.color
            walletPreview.currencyLabel.text = category?.icon
        } else if let categoryPreview = self.preview as? CategoryPreviewCell {
            categoryPreview.titleLabel.text = category?.name
            categoryPreview.iconLabel.text = category?.icon
            categoryPreview.customContentView.backgroundColor = category?.color
        }
    }
    
    private func deleteTransaction(at indexPath: IndexPath) {
        guard indexPath.row < transactions.count else { return }
        let transaction = transactions[indexPath.row]
        try! transactionRepository.delete(object: transaction)
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .left)
        })
    }
    
}
