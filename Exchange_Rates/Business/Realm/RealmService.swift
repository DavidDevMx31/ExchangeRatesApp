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
            print("addObject Error: \(error)")
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
            print("addArrayOfObjects Error: \(error)")
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
            print("updateRealmObject Error: \(error)")
        }
    }
    
    func updateObjectByPK<T: Object>(_ model: T) {
        do{
            try realm.write {
                realm.add(model, update: .modified)
            }
        } catch {
            print("updateRealmObjectByPK Error: \(error)")
        }
    }
    
    func deleteObject<T: Object>(_ model: T) {
        do {
            try realm.write {
                realm.delete(model)
            }
        } catch {
            print("deleteRealmObject Error: \(error)")
        }
    }
    
    func writeRealmPath(){
        print("Path: \(realm.configuration.fileURL!)")
    }
    
    func deleteAll() {
        do{
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deleteAll Error: \(error)")
        }
    }
}
