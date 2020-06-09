//
//  Layout.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 04.06.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

struct DashboardLayout {
    
    var layout: UICollectionViewCompositionalLayout  {
        let layout = UICollectionViewCompositionalLayout { (section, layoutEnvironment) -> NSCollectionLayoutSection? in
            guard let currentSection = Section(rawValue: section) else {
                fatalError("Cannot create section")
            }
            
            switch currentSection {
            case .wallet:
                return self.walletLayout(layoutEnvironment: layoutEnvironment)
            default:
                return self.categoryLayout(layoutEnvironment: layoutEnvironment)
            }
        }
        return layout
    }
    
    private func walletLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let isWide = layoutEnvironment.container.contentSize.width > 500
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupWidth: NSCollectionLayoutDimension = isWide ? .fractionalWidth(0.5) : .fractionalWidth(0.95)
        let groupHeight: NSCollectionLayoutDimension = isWide ? .fractionalWidth(1/3) : .fractionalWidth(3/5)
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(dashboardSectionHeaderHeight))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: headerViewKind, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func categoryLayout(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupWidth: NSCollectionLayoutDimension = .absolute(dashboardCategoryItemWidth)
        let groupHeight: NSCollectionLayoutDimension = .absolute(dashboardCategoryItemHeight)
        let groupSize = NSCollectionLayoutSize(widthDimension: groupWidth, heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(dashboardSectionHeaderHeight))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: headerViewKind, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
}


extension DashboardLayout {
    
    private enum Section: Int {
        case wallet
        case income
        case expense
    }
    
}
