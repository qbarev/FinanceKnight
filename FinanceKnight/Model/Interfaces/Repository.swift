//
//  EntityManager.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 31.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit
import RealmSwift

protocol RepositoryEntity {
    var id: String { get set }
}

protocol Repository {

    associatedtype Entity: RepositoryEntity
    
    func create() -> Entity
    func fetch(predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) -> [Entity]?
    func objectFromId(id: String) -> Entity?
    
    func insert(object: Entity) throws
    func update(_ block: () -> Entity) throws
    func delete(object: Entity) throws
    
    func observeStorage(notification: StorageNotification, completion: @escaping (RepositoryChanges) -> ()) -> StorageNotificationToken
    
}


