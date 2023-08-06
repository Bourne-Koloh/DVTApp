//
//  ForecastEntity.swift
//  weathercore
//
//  Created by Bourne Koloh on 05/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation
import CoreData


/**
 * Mark: Forecast Wrapper class for data stored in CoreData
 */
class ForecastEntity:NSManagedObject{
    /**
     * Mark:
     */
    @NSManaged var id:UInt64
    /**
     * Mark:
     */
    
    @NSManaged var count:UInt64
    /**
     * Mark:
     */
    @NSManaged var cod:String
    /**
     * Mark:
     */
    @NSManaged var message:String
    /**
     * Mark: Stringfied Forecast Entries
     */
    @NSManaged var entries:Data
    /**
     * Mark: Stringfied ForecastCity Object
     */
    @NSManaged var city:Data
    /**
     * Mark:
     */
    @NSManaged var timestamp:Date
    
    public override func awakeFromInsert() {
      super.awakeFromInsert()
        timestamp = Date()
    }
    public override var description: String {
        return CoreDataConstants.FORECAST_TABLE_NAME
    }
}
