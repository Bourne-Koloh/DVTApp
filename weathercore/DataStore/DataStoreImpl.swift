//
//  DataStoreImpl.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation
import CoreData

public class DataStoreImpl:NSObject,IDataStore{
    
    static var _inst:DataStoreImpl?
    
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
    
    private let WeatherTable = "weather"
    
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
    
    
}
