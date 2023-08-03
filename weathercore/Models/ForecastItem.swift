//
//  ForecastItem.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation

public class ForecastItem:NSObject,Codable{
    /**
     * Mark:
     */
    public var id:UInt64 = 0
    /**
     * Mark:
     */
    public var count:UInt64 = 0
    /**
     * Mark:
     */
    public var cod:String = ""
    /**
     * Mark:
     */
    public var message:String = ""
    /**
     * Mark:
     */
    public var entries = [WeatherItem]()
    /**
     * Mark:
     */
    public var city:ForecastCity?
    
    
}
public class ForecastCity:Codable{
    
}
