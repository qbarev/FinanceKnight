//
//  CategoryPickerController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 28.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

protocol CategoryPickerDelegate: class {
    func categoryPicker(_ categoryPicker: CategoryPickerController, didSelectCategory category: Category)
}

class CategoryPickerController: UITableViewController {
    
    weak var delegate: CategoryPickerDelegate!
    var categoryType: CategoryType!
    
    private let categoryRepository = AnyRepository<Category>()
    private var repositoryToken: StorageNotificationToken!
    private var dataSource: [Category]? {
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let predicate = self.categoryType.predicate
        return categoryRepository.fetch(predicate: predicate, sortDescriptor: sortDescriptor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        observeRepository()
    }
    
    deinit {
        repositoryToken.invalidate()
    }
    
}

//MARK: DataSource
extension CategoryPickerController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataSource?.count ?? 0) + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(at: indexPath)
    }
    
}


//MARK: Delegate
extension CategoryPickerController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let row = Row(index: indexPath.row) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        switch row {
        case .category:
            guard let dataSource = self.dataSource else { return }
            let category = dataSource[indexPath.row - 1]
            delegate.categoryPicker(self, didSelectCategory: category)
            navigationController?.popViewController(animated: true)
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
}

//MARK: Segue
extension CategoryPickerController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case categorySettings:
            guard let destinationNC = segue.destination as? UINavigationController else {
                return
            }
            guard let destination = destinationNC.viewControllers.first as? CategorySettingsController else {
                return
            }
            destination.type = self.categoryType
            
        default:
             return
        }
    }
    
}

//MARK: Helpers
extension CategoryPickerController {
    
    enum Row: Int {
        case newCategory = 0
        case category
        
        init?(index: Int) {
            if index != Row.newCategory.rawValue {
                self.init(rawValue:  Row.category.rawValue)
            } else {
                self.init(rawValue: Row.newCategory.rawValue)
            }
        }
        
        var reuseID: String {
            switch self {
            case .newCategory:
                return NewCategoryCell.reuseID
            case .category:
                return CategoryPickerCell.reuseID
            }
        }
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: CategoryPickerCell.reuseID, bundle: .main), forCellReuseIdentifier: CategoryPickerCell.reuseID)
        tableView.register(UINib(nibName: NewCategoryCell.reuseID, bundle: .main), forCellReuseIdentifier: NewCategoryCell.reuseID)
    }
    
    private func observeRepository() {
        repositoryToken = categoryRepository.observeStorage(notification: .didChange, completion: { changes in
            self.tableView.reloadData()
        })
    }
    
    //MARK: Actions
    
    @objc private func createNewCategory(_ sender: UIButton) {
        let identifier = categoryType == .wallet ? walletSettings : categorySettings
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    //MARK: Cell configuring
    private func configureCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let row = Row(index: indexPath.row) else {
            fatalError()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseID, for: indexPath)
        
        switch row {
        case .newCategory:
            return configure(newItemCell: cell)
        default:
            return configure(categoryCell: cell, at: indexPath.row - 1)
        }
    }
    
    private func configure(newItemCell: UITableViewCell) -> UITableViewCell {
        guard let newItemCell = newItemCell as? NewCategoryCell else {
            fatalError()
        }
        newItemCell.newItemButton.addTarget(self, action: #selector(createNewCategory(_:)), for: .touchUpInside)
        return newItemCell
    }
    
    private func configure(categoryCell: UITableViewCell, at index: Int) -> UITableViewCell {
        guard let categoryCell = categoryCell as? CategoryPickerCell else {
            fatalError()
        }
        guard let dataSource = self.dataSource else {
            fatalError()
        }
        let category = dataSource[index]
        categoryCell.configure(category)
        
        return categoryCell
    }
}
