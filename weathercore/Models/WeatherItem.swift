//
//  WeatherItem.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation
/**
 * Mark:
 */
public class WeatherItem:NSObject,Codable,Identifiable{
    /**
     * Mark: City ID. Please note that built-in geocoder functionality has been deprecated. Learn more
     */
    public var id:UInt64 = 0
    /**
     * Mark: Internal parameter
     */
    public var base:String = ""
    /**
     * Mark: City name. Please note that built-in geocoder functionality has been deprecated
     */
    public var name:String = ""
    /**
     * Mark: Internal parameter
     */
    public var cod:String = ""
    /**
     * Mark: Shift in seconds from UTC
     */
    public var timezone:UInt64 = 0
    /**
     * Mark: Visibility, meter.
     * The maximum value of the visibility is 10km
     */
    public var visibility:Double = 0.0
    /**
     * Mark: Time of data calculation, unix, UTC
     */
    public var dt = Date()
    /**
     * Mark: A number of timestamps returned in the API response
     */
    public var count:UInt64 = 0
    
    /**
     * Mark:
     */
   public var pop:Double = 0.0
    
    /**
     * Mark:
     */
    public var sys:SysItem?
    /**
     * Mark:
     */
    public var clouds:CloudsItem?
    /**
     * Mark:
     */
    public var rain:RainItem?
    /**
     * Mark:
     */
    public var wind:WindsItem?
    /**
     * Mark:
     */
    public var main:InfoItem?
    /**
     * Mark:
     */
    public var weather = [DetailsItem]()
    /**
     * Mark:
     */
    public var coord:CoordItem?
    /**
     * Mark:
     */
    public var dtText:String = ""
    
    private enum CodingKeys: String, CodingKey {
        case dt
        case id
        case base
        case visibility
        case timezone
        case name
        case sys
        case clouds
        case rain
        case wind
        case main
        case weather
        case coord
        case pop
        case dtText = "dt_txt"
        case count = "cnt"
    }
    
    public override init() {
        //
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .dt) {
            dt = Date(timeIntervalSince1970: TimeInterval(val))
        }
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .id){
            id = val
        }
        if let val = try? container.decodeIfPresent(String.self, forKey: .base){
            base = val
        }
        
        if let val = try? container.decode(Double.self, forKey: .visibility){
            visibility = val
        }
        
        if let val = try? container.decode(UInt64.self, forKey: .timezone){
            timezone = val
        }
        
        if let val = try? container.decode(String.self, forKey: .name){
            name = val
        }
        
        if let val = try? container.decode(SysItem.self, forKey: .sys){
            sys = val
        }
        
        if let val = try? container.decode(CloudsItem.self, forKey: .clouds){
            clouds = val
        }
        
        if let val = try? container.decode(RainItem.self, forKey: .rain){
            rain = val
        }
        
        if let val = try? container.decode(WindsItem.self, forKey: .wind){
            wind = val
        }
        
        if let val = try? container.decode(InfoItem.self, forKey: .main){
            main = val
        }
        
        if let val = try? container.decode([DetailsItem].self, forKey: .weather){
            weather = val
        }
        
        if let val = try? container.decode(CoordItem.self, forKey: .coord){
            coord = val
        }
        
        if let val = try? container.decode(Double.self, forKey: .pop){
            pop = val
        }
        
        if let val = try? container.decode(UInt64.self, forKey: .count){
            count = val
        }
        
        if let val = try? container.decode(String.self, forKey: .dtText){
            dtText = val
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id , forKey: .id)
        try? container.encode(dt , forKey: .dt)
        try? container.encode(base , forKey: .base)
        try? container.encode(visibility , forKey: .visibility)
        try? container.encode(timezone , forKey: .timezone)
        try? container.encode(name , forKey: .name)
        try? container.encode(sys , forKey: .sys)
        try? container.encode(clouds , forKey: .clouds)
        try? container.encode(rain , forKey: .rain)
        try? container.encode(wind , forKey: .wind)
        try? container.encode(main , forKey: .main)
        try? container.encode(weather , forKey: .weather)
        try? container.encode(coord , forKey: .coord)
        try? container.encode(pop , forKey: .pop)
        try? container.encode(count , forKey: .count)
        try? container.encode(dtText , forKey: .dtText)
        
    }
}
/**
 * Mark:
 */
public class CoordItem:Codable{
    /**
     * Mark: Longitude of the location
     */
    public var lat:Double = 0.0
    /**
     * Mark: Latitude of the location
     */
    public var lng:Double = 0.0
    
    private enum CodingKeys: String, CodingKey {
        case lat
        case lng = "lon"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(Double.self, forKey: .lat) {
            lat = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .lng) {
            lng = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(lat , forKey: .lat)
        try? container.encode(lng , forKey: .lng)
        
    }
}

/**
 * Mark: more info Weather condition codes
 */
public class DetailsItem:Codable,Identifiable{
    /**
     * Mark: Weather condition id
     */
    public var id:UInt64 = 0
    /**
     * Mark: Group of weather parameters (Rain, Snow, Extreme etc.)
     */
    public var main:String = ""
    /**
     * Mark: Weather condition within the group. You can get the output in your language
     */
    public var description:String = ""
    /**
     * Mark: Weather icon id
     */
    public var icon:String = ""
    
    private enum CodingKeys: String, CodingKey {
        case id
        case main
        case description
        case icon
    }
    
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .id) {
            id = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .main) {
            main = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .description) {
            description = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .icon) {
            icon = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id , forKey: .id)
        try? container.encode(main , forKey: .main)
        try? container.encode(description , forKey: .description)
        try? container.encode(icon , forKey: .icon)
        
    }
}
/**
 * Mark:
 */
public class InfoItem:Codable{
    
    /**
     * Mark: Temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
     */
    public var temp:Double = 0.0
    /**
     * Mark: Temperature.
     * This temperature parameter accounts for the human perception of weather.
     * Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
     */
    public var feelsLike:Double = 0.0
    /**
     * Mark: Minimum temperature at the moment.
     * This is minimal currently observed temperature (within large megalopolises and urban areas).
     * Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
     */
    public var tempMin:Double = 0.0
    /**
     * Mark: Atmospheric pressure on the sea level, hPa
     */
    public var seaLevel:Double = 0.0
    /**
     * Mark: Maximum temperature at the moment.
     * This is maximal currently observed temperature (within large megalopolises and urban areas).
     * Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit.
     */
    public var tempMax:Double = 0.0
    /**
     * Mark: Atmospheric pressure (on the sea level, if there is no sea_level or grnd_level data), hPa
     */
    public var pressure:Double = 0.0
    /**
     * Mark: Humidity, %
     */
    public var humidity:Double = 0.0
    /**
     * Mark: Atmospheric pressure on the ground level, hPa
     */
    public var groundLevel:Double = 0.0
    /**
     * Mark: Atmospheric pressure on the ground level, hPa
     */
    public var tempKF:Double = 0.0
    
    private enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case seaLevel = "sea_level"
        case tempMax = "temp_max"
        case pressure = "preassure"
        case humidity
        case groundLevel = "grnd_level"
        case tempKF = "temp_kf"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(Double.self, forKey: .temp) {
            temp = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .feelsLike) {
            feelsLike = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .tempMin) {
            tempMin = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .tempMax) {
            tempMax = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .seaLevel) {
            seaLevel = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .pressure) {
            pressure = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .humidity) {
            humidity = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .groundLevel) {
            groundLevel = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .tempKF) {
            tempKF = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(temp , forKey: .temp)
        try? container.encode(feelsLike , forKey: .feelsLike)
        try? container.encode(tempMax , forKey: .tempMax)
        try? container.encode(tempMin , forKey: .tempMin)
        try? container.encode(seaLevel , forKey: .seaLevel)
        try? container.encode(pressure , forKey: .pressure)
        try? container.encode(humidity , forKey: .humidity)
        try? container.encode(groundLevel , forKey: .groundLevel)
        try? container.encode(tempKF , forKey: .tempKF)
        
    }
}
/**
 * Mark:
 */
public class WindsItem:Codable{
    
    /**
     * Mark: Wind speed. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour.
     */
    public var speed:Double = 0.0
    /**
     * Mark: Wind direction, degrees (meteorological)
     */
    public var deg:Double = 0.0
    /**
     * Mark: Wind gust. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour
     */
    public var gust:Double = 0.0
    
    private enum CodingKeys: String, CodingKey {
        case speed
        case deg
        case gust
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(Double.self, forKey: .speed) {
            speed = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .deg) {
            deg = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .gust) {
            gust = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(speed , forKey: .speed)
        try? container.encode(deg , forKey: .deg)
        try? container.encode(gust , forKey: .gust)
        
    }
}
/**
 * Mark:
 */
public class RainItem:Codable{
    
    /**
     * Mark: (where available) Rain volume for the last 1 hour, mm.
     * Please note that only mm as units of measurement are available for this parameter.
     */
    public var rainVolume1Hour:Double = 0.0
    
    /**
     * Mark:(where available) Rain volume for the last 3 hours, mm.
     * Please note that only mm as units of measurement are available for this parameter.
     */
    public var rainVolume3Hour:Double = 0.0
    
    private enum CodingKeys: String, CodingKey {
        case rainVolume1Hour = "lh"
        case rainVolume3Hour = "3h"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(Double.self, forKey: .rainVolume1Hour) {
            rainVolume1Hour = val
        }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .rainVolume3Hour) {
            rainVolume3Hour = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(rainVolume1Hour , forKey: .rainVolume1Hour)
        try? container.encode(rainVolume3Hour , forKey: .rainVolume3Hour)
        
    }
}

/**
 * Mark:
 */
public class SnowItem:Codable{
    
    /**
     * Mark: (where available) Rain volume for the last 1 hour, mm.
     * Please note that only mm as units of measurement are available for this parameter.
     */
    public var rainVolume1Hour:Double = 0.0
    
    /**
     * Mark:(where available) Rain volume for the last 3 hours, mm.
     * Please note that only mm as units of measurement are available for this parameter.
     */
    public var rainVolume3Hour:Double = 0.0
    
    private enum CodingKeys: String, CodingKey {
        case rainVolume1Hour = "lh"
        case rainVolume3Hour = "3h"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(Double.self, forKey: .rainVolume1Hour) {
            rainVolume1Hour = val
        }
        
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .rainVolume3Hour) {
            rainVolume3Hour = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(rainVolume1Hour , forKey: .rainVolume1Hour)
        try? container.encode(rainVolume3Hour , forKey: .rainVolume3Hour)
        
    }
}
/**
 * Mark:
 */
public class CloudsItem:Codable{
    
    /**
     * Mark: Cloudiness, %
     */
    public var all:Double = 0.0
    
    private enum CodingKeys: String, CodingKey {
        case all
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(Double.self, forKey: .all) {
            all = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(all , forKey: .all)
        
        
    }
}

/**
 * Mark:
 */
public class SysItem:Codable,Identifiable{
    
    /**
     * Mark:  Internal parameter
     */
    public var id:UInt64 = 0
    /**
     * Mark:  Sunrise time, unix, UTC
     */
    public var sunrise:UInt64 = 0
    /**
     * Mark: Sunset time, unix, UTC
     */
    public var sunset:UInt64 = 0
    /**
     * Mark:  Internal parameter
     */
    public var type:Int = 0
    /**
     * Mark: Country code (GB, JP etc.)
     */
    public var country:String = ""
    /**
     * Mark: Country code (GB, JP etc.)
     */
    public var pod:String = ""
    
    
    private enum CodingKeys: String, CodingKey {
        case id
        case sunrise
        case sunset
        case type
        case country
        case pod
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .id) {
            id = val
        }
        
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .sunrise) {
            sunrise = val
        }
        
        if let val = try? container.decodeIfPresent(UInt64.self, forKey: .sunset) {
            sunset = val
        }
        
        if let val = try? container.decodeIfPresent(Int.self, forKey: .type) {
            type = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .country) {
            country = val
        }
        
        if let val = try? container.decodeIfPresent(String.self, forKey: .pod) {
            pod = val
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        //
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(id , forKey: .id)
        try? container.encode(sunrise , forKey: .sunrise)
        try? container.encode(sunset , forKey: .sunset)
        try? container.encode(type , forKey: .type)
        try? container.encode(country , forKey: .country)
        try? container.encode(pod , forKey: .pod)
        
    }
}
