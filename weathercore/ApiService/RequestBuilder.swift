//
//  RequestBuilder.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation

internal class RequestBuider{
    
    static let scheme = "https"
    static let host = "api.openweathermap.org"
    static let path = "/data/2.5"
    static let demoKey = "5c137103d4cc44f4ffe795af8d6f6d6e"
      
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
          URLQueryItem(name: "lat", value: lat.toString()),
        URLQueryItem(name: "lon", value: lng.toString()),
        URLQueryItem(name: "appid", value: appid)
      ]
      
      return components
    }
    
}
