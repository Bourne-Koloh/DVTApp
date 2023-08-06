//
//  RequestBuilder.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation


/**
 * MARK: This class helps build the weather API request query parameters
 */
internal class RequestBuider{
    
    static let scheme = "https"
    static let host = "api.openweathermap.org"
    static let path = "/data/2.5"
    static let demoKey = "<key here >"
      
    static func buildWeatherApiComponents(latitude lat:Double,longitude lng:Double) -> URLComponents {
        var components = URLComponents()
        components.scheme = RequestBuider.scheme
        components.host = RequestBuider.host
        components.path = RequestBuider.path + "/weather"
        
        //Prefer API Key set in Info.plist
        var appid = AppConfig.Shared.weatherKey
        //
        if appid == nil && AppConfig.Shared.isDevt {
            //
            appid = demoKey
        }

        components.queryItems = [
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lat", value: lat.toString()),
          URLQueryItem(name: "lon", value: lng.toString()),
          URLQueryItem(name: "appid", value: appid)
        ]
        
        return components
      }
    
  static func buildForecastApiComponents(latitude lat:Double,longitude lng:Double) -> URLComponents {
      var components = URLComponents()
      components.scheme = RequestBuider.scheme
      components.host = RequestBuider.host
      components.path = RequestBuider.path + "/forecast"
      
      //Prefer API Key set in Info.plist
      var appid = AppConfig.Shared.weatherKey
      //
      if appid == nil && AppConfig.Shared.isDevt {
          //
          appid = demoKey
      }
      
      components.queryItems = [
        URLQueryItem(name: "units", value: "metric"),
        URLQueryItem(name: "lat", value: lat.toString()),
        URLQueryItem(name: "lon", value: lng.toString()),
        URLQueryItem(name: "appid", value: appid)
      ]
      
      return components
    }
    
}
