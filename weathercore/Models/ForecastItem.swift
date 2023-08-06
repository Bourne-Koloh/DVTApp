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
    
    public var dt = Date()
    
    public override init() {
        super.init()
    }
    
    private enum CodingKeys: String, CodingKey {
        case count = "cnt"
        case id
        case cod
        case message
        case entries = "list"
        case city
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .id) {
            id = val
        }
        
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .count) {
            count = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .cod) {
            cod = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .message) {
            message = val
        }
        
        if let val = try? container.decodeIfPresent([WeatherItem].self, forKey: .entries) {
            entries = val
        }
        
        
        if let val = try? container.decodeIfPresent(ForecastCity.self, forKey: .city) {
            city = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id , forKey: .id)
        try? container.encode(count , forKey: .count)
        try? container.encode(cod , forKey: .cod)
        try? container.encode(message , forKey: .message)
        try? container.encode(entries , forKey: .entries)
        try? container.encode(city , forKey: .city)
    }
}


public class ForecastCity:Codable{
    
    /**
     * Mark:
     */
    public var id:UInt64 = 0
    /**
     * Mark:
     */
    public var population:UInt64 = 0
    /**
     * Mark:
     */
    public var name:String = ""
    /**
     * Mark:
     */
    public var country:String = ""
    /**
     * Mark:
     */
    public var timezone:UInt64 = 0
    /**
     * Mark:
     */
    public var sunrise:UInt64 = 0
    /**
     * Mark:
     */
    public var sunset:UInt64 = 0
    
    
    private enum CodingKeys: String, CodingKey {
        case population
        case id
        case name
        case country
        case timezone
        case sunrise
        case sunset
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .id) {
            id = val
        }
        
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .population) {
            population = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .name) {
            name = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .country) {
            country = val
        }
        
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .timezone) {
            timezone = val
        }
        
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .sunrise) {
            sunrise = val
        }
        
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .sunset) {
            sunset = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id , forKey: .id)
        try? container.encode(population , forKey: .population)
        try? container.encode(name , forKey: .name)
        try? container.encode(country , forKey: .country)
        try? container.encode(timezone , forKey: .timezone)
        try? container.encode(sunrise , forKey: .sunrise)
        try? container.encode(sunset , forKey: .sunset)
        
    }
}
