//
//  DashboardController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 24.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

class DashboardController: UICollectionViewController {
    
    private let categoryRepository = AnyRepository<Category>()
    
    private var wallets: [Category]? {
        fetchCategory(CategoryType.wallet.predicate)
    }
    private var incomes: [Category]? {
        fetchCategory(CategoryType.income.predicate)
    }
    private var expenses: [Category]? {
        fetchCategory(CategoryType.expense.predicate)
    }
    
    private var walletToken: StorageNotificationToken!
    private var incomeToken: StorageNotificationToken!
    private var expenseToken: StorageNotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        observeRepository()
    }
    
    deinit {
        invalidateTokens()
    }
    
}

// MARK: UICollectionViewDataSource
extension DashboardController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        chooseDataSource(section)?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        configureCell(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let section = Section.init(index: indexPath.section) else {
            fatalError("Cannot create section")
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: headerViewKind, withReuseIdentifier: HeaderView.reuseID, for: indexPath) as! HeaderView
        view.titleLabel?.text = section.rawValue
        view.addButton.tag = indexPath.section
        view.addButton.addTarget(self, action: #selector(addItem(sender:)), for: .touchUpInside)
        
        return view
    }
    
}

//MARK: Segue
extension DashboardController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case categorySettings:
            guard let destinationNC = segue.destination as? UINavigationController else { return }
            guard let destination = destinationNC.viewControllers.first as? CategorySettingsController else { return }
            guard let sender = sender as? UIButton else { return }
            destination.type = CategoryType(rawValue: sender.tag)
        case categoryOverview:
            guard let destination = segue.destination as? CategoryOverviewController else { return }
            guard let category = sender as? Category else { return }
            destination.category = category
        default:
            return
        }
    }
    
}


// MARK: UICollectionViewDelegate
extension DashboardController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource = chooseDataSource(indexPath.section) else { return }
        
        let category = dataSource[indexPath.row]
        
        performSegue(withIdentifier: categoryOverview, sender: category)
    }
    
}


//MARK: Helpers
extension DashboardController {
    
    fileprivate enum Section: String, CaseIterable {
        case wallet = "Wallets"
        case income = "Incomes"
        case expense = "Expenses"
  
        init?(index: Int) {
            guard index < Section.allCases.count else {
                return nil
            }
            let rawValue = Section.allCases[index].rawValue
            self.init(rawValue: rawValue)
        }

        func reuseID(indexPath: IndexPath) -> String {
            switch  self {
            case .wallet:
                return WalletPreviewCell.reuseID
            default:
                return DashboardItemCell.reuseID
            }
        }
        
    }
    
    //MARK: Initial configuration
    private func fetchCategory(_ predicate: NSPredicate?) -> [Category]? {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        return categoryRepository.fetch(predicate: predicate, sortDescriptor: sortDescriptor)
    }

    private func configureCollectionView() {
        collectionView.collectionViewLayout = DashboardLayout().layout
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: headerViewKind, withReuseIdentifier: HeaderView.reuseID)
        collectionView.register(UINib(nibName: "DashboardItemCell", bundle: .main), forCellWithReuseIdentifier: DashboardItemCell.reuseID)
        collectionView.register(UINib(nibName: "WalletPreviewCell", bundle: .main), forCellWithReuseIdentifier: WalletPreviewCell.reuseID)
    }
    
    private func observeRepository() {
        walletToken = observe(.wallet)
    }
    
    private func invalidateTokens() {
        walletToken.invalidate()
        incomeToken.invalidate()
        expenseToken.invalidate()
    }
    
    private func observe(_ categoryType: CategoryType) -> StorageNotificationToken {
        let token = categoryRepository.observeStorage(notification: .didChange, completion: { [unowned self] changes in
            self.collectionView.reloadData()
        })
        
        return token
    }
    
    //MARK: Cells configuration
    private func configureCell(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = chooseDataSource(indexPath.section) else {
            fatalError()
        }
        guard let section = Section(index: indexPath.section) else {
            fatalError()
        }
        
        let item = dataSource[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: section.reuseID(indexPath: indexPath), for: indexPath)
        
        switch section {
        case .wallet:
            return configureWalletCell(cell, with: item)
        default:
            return configureCategoryCell(cell, with: item)
        }
    }
    
    private func configureWalletCell(_ cell: UICollectionViewCell, with wallet: Category) -> UICollectionViewCell {
        guard let walletCell = cell as? WalletPreviewCell else {
            fatalError("Cannot create wallet cell")
        }
        
        walletCell.configure(wallet)
        
        return walletCell
    }
    
    private func configureCategoryCell(_ cell: UICollectionViewCell, with category: Category) -> UICollectionViewCell {
        guard let categoryCell = cell as? DashboardItemCell else {
            fatalError("Cannot create wallet cell")
        }
        categoryCell.configure(category)
        
        return categoryCell
    }
    
    @objc private func addItem(sender: UIButton) {
        guard let section = Section(index: sender.tag) else {
            fatalError()
        }
        
        switch section {
        case .wallet:
            performSegue(withIdentifier: walletSettings, sender: nil)
        case .income:
            performSegue(withIdentifier: categorySettings, sender: sender)
        case .expense:
            performSegue(withIdentifier: categorySettings, sender: sender)

        }
    }
    
    //MARK: Helpers
    private func chooseDataSource(_ section: Int) -> [Category]? {
        guard let currentSection = Section(index: section) else { return nil}
        
        switch currentSection {
        case .wallet:
            return wallets
        case .income:
            return incomes
        case .expense:
            return expenses
        }
    }
    
}



