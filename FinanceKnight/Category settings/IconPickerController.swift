//
//  IconPickerController.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 27.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

protocol IconPickerDelegate: class {
    func iconPickerController(_ iconPickerController: IconPickerController, didSelectIcon icon: String)
}

class IconPickerController: UICollectionViewController {
    
    weak var delegate: IconPickerDelegate?
    
    private let icons = ["🎄", "🍏", "🍷", "🍺", "🍴",
                         "⚽️", "🏀", "🏈", "⚾️", "🥎",
                         "🏐", "🏉", "🎾", "🥏", "🎱",
                         "🏓", "🏸", "🥅", "🏒", "🏑",
                         "🥍", "🏏", "⛳️", "🚗", "🚕",
                         "🏠", "🏖", "🏝", "✈️", "📱",
                         "💻", "📦", "💊", "💉", "🎥",
                         "📞", "💈", "🛠", "🏛", "🚲",
                         "🍔", "🎂", "🍼", "🐶", "🐱"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
    }
    
    private func configureCollectionView() {
        collectionView.register(UINib(nibName: IconPickerCell.reuseID, bundle: .main), forCellWithReuseIdentifier: IconPickerCell.reuseID)
    }


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconPickerCell.reuseID, for: indexPath) as! IconPickerCell
        
        cell.iconLabel.text = icons[indexPath.row]
    
        return cell
    }
    
}

//MARK: Delegate
extension IconPickerController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.iconPickerController(self, didSelectIcon: icons[indexPath.row])
        collectionView.deselectItem(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
    }
    
}


extension IconPickerController: UICollectionViewDelegateFlowLayout {
    
    var insets: CGFloat {
        collectionView.layoutMargins.left + collectionView.layoutMargins.right
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        collectionView.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    var itemsSpacing: CGFloat {
        flowLayout?.minimumInteritemSpacing ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columnCount: CGFloat = collectionView.bounds.width > 500 ? 8 : 5
        let size = (collectionView.bounds.width - insets - itemsSpacing * ( columnCount - 1 ) ) / columnCount
        
        return CGSize(width: size, height: size)
    }
    
}
