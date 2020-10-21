//
//  RealmService.swift
//  Exchange_Rates
//
//  Created by David Ali on 21/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    
    private init() { }
    static let instance = RealmService()
    
    var realm = try! Realm()
    
    func addObject<T: Object>(_ model: T){
        do {
            try realm.write {
                realm.add(model)
            }
        } catch  {
            print("An error ocurred in RealmService.addObject. Error description: \(error.localizedDescription)")
        }
    }
    
    func addArrayOfObjectsWithPK<T: Object>(_ model: [T]) {
        do {
            try realm.write {
                for entity in model {
                    realm.add(entity, update: .modified)
                }
            }
        } catch {
            print("An error ocurred in RealmService.addArrayOfObjects. Error description: \(error.localizedDescription)")
        }
    }
    
    func updateObject<T: Object>(_ model: T, with dictionary: [String: Any?]) {
        do {
            try realm.write {
                for (key, value) in dictionary{
                    model.setValue(value, forKey: key)
                }
            }
        } catch  {
            print("An error ocurred in RealmService.updateRealmObject. Error description: \(error.localizedDescription)")
        }
    }
    
    func updateObjectByPK<T: Object>(_ model: T) {
        do{
            try realm.write {
                realm.add(model, update: .modified)
            }
        } catch {
            print("An error ocurred in RealmService.updateRealmObjectByPK Error description: \(error.localizedDescription)")
        }
    }
    
    func deleteObject<T: Object>(_ model: T) {
        do {
            try realm.write {
                realm.delete(model)
            }
        } catch {
            print("An error ocurred in RealmService.deleteRealmObject Error description: \(error.localizedDescription)")
        }
    }
    
    func deleteAll() {
        do{
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deleteAll Error: \(error.localizedDescription)")
        }
    }
    
    func writeRealmPath(){
        print("Current Realm path: \(realm.configuration.fileURL!)")
    }
}
