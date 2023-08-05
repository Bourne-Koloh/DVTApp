//
//  DataStoreImpl.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation
import CoreData

public class DataStoreImpl:NSObject,IDataStore{
    
    private static var _inst:DataStoreImpl?
    
    static var Shared:IDataStore{
        
        get {
            if _inst == nil {
                //Init...
                _inst = DataStoreImpl()
            }
            
            return _inst!
        }
    }
    
    

    private var inMemory = false
    
    private override init() {
        super.init()
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        var container:NSPersistentContainer
        //
        if #available(iOS 13.0, *) {
            //
            container  = NSPersistentCloudKitContainer(name: "weatherapp")
            
            if inMemory {
                container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            }
        } else {
            // Fallback on earlier versions
            container = NSPersistentContainer(name: "weatherapp")
        }
        //Core Data can infer a mapping model in many cases when you enable the shouldInferMappingModelAutomatically flag on the NSPersistentStoreDescription. Core Data can automatically look at the differences in two data models and create a mapping model between them.
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        //
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    //
    private lazy var backgroundContext: NSManagedObjectContext = {
        //
        let newbackgroundContext = persistentContainer.newBackgroundContext()
        //
        newbackgroundContext.automaticallyMergesChangesFromParent = true
        //
        return newbackgroundContext
    }()
    
    
    public func dispose() {
        //
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func loadForecastItems() -> [ForecastItem]{
        var list = [ForecastItem]()
         //
        let fetchRequest = NSFetchRequest<ForecastEntity>(entityName:CoreDataConstants.FORECAST_TABLE_NAME)
         
         //3
         do {
             let records = try backgroundContext.fetch(fetchRequest)
             
             let decoder = JSONDecoder()
             
            for (i,r0) in records.enumerated() {
                 
                let item = ForecastItem()
                 //
                item.cod = r0.cod
                item.id = r0.id > 0 ? r0.id : UInt64(i)
                item.dt = r0.timestamp
                item.message = r0.message
                item.count = r0.count
                 //
                item.city = try? decoder.decode(ForecastCity.self, from: r0.city.data(using: .utf8)!)
                 //
                item.entries = try! decoder.decode([WeatherItem].self, from: r0.entries.data(using: .utf8)!)
                 
                 //
                 list.append(item)
             }
             
         } catch let error as NSError {
           LogUtils.Log(from: self,with: "Could not fetch forecast records. \(error), \(error.userInfo)")
         }
        return list
    }
    //
    public func addForecastItem(with item :ForecastItem) -> Bool{
        //
        let fetchRequest = NSFetchRequest<ForecastEntity>(entityName: CoreDataConstants.FORECAST_TABLE_NAME)
        
        //Account
        var predicates = [NSPredicate]()
        let accPredicate = NSPredicate(format: "\(#keyPath(ForecastEntity.cod)) = %@", item.cod)
        predicates.append(accPredicate)
        //
        
        //Combine Rules..
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        //
        do {
            //Get matching entries ..
            let matches = try backgroundContext.fetch(fetchRequest)
            
            var entity:ForecastEntity?
            
            //Drop them..
            if matches.count > 0{
                //
                entity = matches[0]
                //
                if(matches.count > 1){
                    //Clear Records..
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.FORECAST_TABLE_NAME))
                    //
                    try backgroundContext.execute(deleteRequest)
                    try backgroundContext.save()
                    //
                }
            }else{
                // 2 Create a new entry
                entity = ForecastEntity(context: backgroundContext)
            }
            
            // 3
            entity?.id = item.id
            entity?.cod = item.cod
            //
            entity?.timestamp = Date()
            //
            entity?.message = item.message
            
            let encoder = JSONEncoder()
            
            if let json  = try? encoder.encode(item.city){
                entity?.city =  String(data: json, encoding: .utf8)!
            }
            
            if let json  = try? encoder.encode(item.entries) {
                entity?.entries = String(data: json, encoding: .utf8)!
            }
            
        } catch {
            return false
        }
        
        
        // 4
        do {
          
          try backgroundContext.save()
          //people.append(person)
          LogUtils.Log(from: self,with: "Forecast Record updated.")
          
        } catch let error as NSError {
          LogUtils.Log(from: self,with: "Forecast Record Could not save. \(error), \(error.userInfo)")
          return false
        }
          
        return true
    }
    
    
    public func dropForecastRecord(with entry:ForecastItem)-> Bool{
     
        //Clear Records..
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataConstants.FORECAST_TABLE_NAME)
        //Create match rules ..
        //Account
        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "\(#keyPath(ForecastEntity.cod)) = %@", entry.cod))
         //Kind
        predicates.append(NSPredicate(format: "\(#keyPath(ForecastEntity.timestamp)) = %@", argumentArray: [entry.dt]))
         //Name
        predicates.append(NSPredicate(format: "\(#keyPath(ForecastEntity.id)) = %@", argumentArray: [entry.id]))
         //Combine Rules..
         fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
         //
         //
         do {
             let users = try backgroundContext.fetch(fetchRequest)
             if users.count > 0{
                 //
                 let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                 //
                 try backgroundContext.execute(deleteRequest)
                 try backgroundContext.save()
             }
         } catch {
             LogUtils.Log(from: self,with: "There was an error dropping Forecast entry: \(error)")
             return false
         }
         
         return true
     }
}
