//
//  RealmManager.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 24.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import Foundation
import RealmSwift

class AnyRepository<Entity: RepositoryEntity>: Repository where Entity: Object {

    private let realm = try! Realm()
    private var realmToken: NotificationToken!
    
    init() {
        setup()
    }
    
    deinit {
        self.realmToken.invalidate()
    }
    
    private func setup() {
        let objects = realm.objects(Entity.self)
        self.realmToken = objects.observe({ (changes) in
            switch changes {
            case .initial:
                let repositoryChanges = RepositoryChanges(notification: .initial, results: [], deletions: [], insertions: [], modifications: [])
                NotificationCenter.default.post(name: .initRepository, object: repositoryChanges)
                
            case .update(let results, let deletions, let insertions, let modifications):
                let repositoryChanges = RepositoryChanges(notification: .didChange,
                                                          results: Array(results),
                                                          deletions: deletions,
                                                          insertions: insertions,
                                                          modifications: modifications)
                NotificationCenter.default.post(name: .didChangeRepository, object: repositoryChanges)
                
            case .error(let error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    func create() -> Entity {
        Entity()
    }
    
    func fetch(predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) -> [Entity]? {
        var objects = realm.objects(Entity.self)
        
        if let predicate = predicate {
            objects = objects.filter(predicate)
        }
        if let sortDescriptor = sortDescriptor, let key = sortDescriptor.key {
            objects = objects.sorted(byKeyPath: key, ascending: sortDescriptor.ascending)
        }
        
        let objectsArray = Array(objects)
        
        return objectsArray
    }
    
    func objectFromId(id: String) -> Entity? {
        realm.object(ofType: Entity.self, forPrimaryKey: id)
    }
    
    func insert(object: Entity) throws {
        try realm.write() {
            realm.add(object)
        }
    }
    
    func insert(objects: [Entity]) throws {
        try realm.write() {
            realm.add(objects)
        }
    }
    
    func update(_ block: () -> Entity) throws {
        try realm.write() {
            let object = block()
            realm.add(object, update: .modified)
        }
    }
    func update(_ block: () -> [Entity]) throws {
        try realm.write() {
            let objects = block()
            realm.add(objects, update: .modified)
        }
    }
    
    func delete(object: Entity) throws {
        try realm.write() {
            realm.delete(object)
        }
    }
    
    func observeStorage(notification: StorageNotification, completion: @escaping (RepositoryChanges) -> ()) -> StorageNotificationToken {
        let center = NotificationCenter.default
        
        let token = center.addObserver(forName: notification.notificationName,
                                   object: nil,
                                   queue: nil,
                                   using: { notification in
                                    guard let changes = notification.object as? RepositoryChanges else { return }
                                    completion(changes)
        })
        
        return StorageNotificationToken(token: token, center: center)
    }

}

//MARK: Supporting structs
class StorageNotificationToken {
    
    private let token: NSObjectProtocol
    private let center: NotificationCenter
    
    init(token: NSObjectProtocol, center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    func invalidate() {
        self.center.removeObserver(token)
    }
    
}

struct RepositoryChanges {
    let notification: StorageNotification
    
    let results: [RepositoryEntity]
    let deletions: [Int]
    let insertions: [Int]
    let modifications: [Int]
}

enum StorageNotification     {
    case initial
    case didChange
    
    var notificationName: Notification.Name {
        switch self {
        case .initial:
            return .initRepository
        case .didChange:
            return .didChangeRepository
        }
    }
}

enum ManagerError: Error {
    case invalidType
    
    var localizedDescription: String {
        switch self {
        case .invalidType:
            return "Object doesn't conforms storage's object type"
        }
    }
}
