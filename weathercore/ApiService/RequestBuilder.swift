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
    static let key = "<your key>"
      
    static func buildWeatherApiComponents(latitude lat:Double,longitude lng:Double) -> URLComponents {
        var components = URLComponents()
        components.scheme = RequestBuider.scheme
        components.host = RequestBuider.host
        components.path = RequestBuider.path + "/weather"
        
        components.queryItems = [
            URLQueryItem(name: "lat", value: lat.toString()),
          URLQueryItem(name: "lon", value: lng.toString()),
          URLQueryItem(name: "appid", value: key)
        ]
        
        return components
      }
    
  static func buildForecastApiComponents(latitude lat:Double,longitude lng:Double) -> URLComponents {
      var components = URLComponents()
      components.scheme = RequestBuider.scheme
      components.host = RequestBuider.host
      components.path = RequestBuider.path + "/forecast"
      
      components.queryItems = [
          URLQueryItem(name: "lat", value: lat.toString()),
        URLQueryItem(name: "lon", value: lng.toString()),
        URLQueryItem(name: "appid", value: key)
      ]
      
      return components
    }
    
}
