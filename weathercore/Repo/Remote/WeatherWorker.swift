//
//  WeatherWorker.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation
import Combine

let dateFormatter = DateFormatter()

/**
 * MARK: Abstraction of the weather features
 */
public protocol IWeatherWorker:NSObject {
    
    /// Get the shared singletone implementation of this protocol
    /// - Returns: Shared instance of this protocal
    static func getImpl() -> IWeatherWorker
    
    
    /// Load current weather information for specified location
    /// - Warning: - Call requires iOS 13.x or higher
    /// - Parameter location: The location(lat,lon) of this device/user
    /// - Returns: a publisher of the request results
    @available(iOS 13.0, *)
    func loadCurrentWeather(withLocation coords: (Double,Double)) -> AnyPublisher<WeatherItem, RequestState>
    /// Load forecast weather for specified location
    /// - Warning: - Call requires iOS 13.x or higher
    /// - Parameter location: The location of this device/user
    /// - Returns: a publisher of the request results
    @available(iOS 13.0, *)
    func loadForecastWeather(forLocation coords: (Double,Double)) -> AnyPublisher<ForecastItem, RequestState>
    
    
    
    /// Implemenation of iOS < 13.* to load current weather information for specified location
    /// - Parameter location: The location(lat,lon) for the device location
    /// - Parameter completion: A completion handler to receive the request results
    func loadCurrentWeather(withLocation coords: (Double,Double),_ completion: @escaping ( WeatherItem?, RequestState) -> Void) -> Swift.Void
    
    /// Implemenation of iOS < 13.* to load forecast weather for specified location
    /// - Parameter location: The location(lat,lon) for the device location
    /// - Parameter completion: A completion handler to receive the request results
    func loadForecastWeather(forLocation coords: (Double,Double), _ completion: @escaping ( ForecastItem?, RequestState) -> Void) -> Swift.Void
}

extension IWeatherWorker{
    ///Default Implementation
    public static func getImpl() -> IWeatherWorker{
        return WeatherWorkerImpl.Shared
    }
}

///The class for managing all requests in this app
public class WeatherWorkerImpl :NSObject, IWeatherWorker {
    //MARK: Local queue for managing http requests
    internal let operationQueue = OperationQueue()
    //MARK: Local queue for managing app background tasks
    internal let dispatchQueue = DispatchQueue(label: "dvtapp.queue.dispatcheueuq")
    //Shared Instance
    fileprivate static var _inst:IWeatherWorker? = nil
    //
    static var Shared:IWeatherWorker{
        get{
            if _inst == nil {
                _inst = WeatherWorkerImpl()
            }
            return _inst!
        }
        set{}
    }
    //
    internal lazy var requestsSession: URLSession = {
        //
        let configuration = URLSessionConfiguration.default
        configuration.tlsMinimumSupportedProtocol = .sslProtocolAll
        //
        return URLSession(configuration: configuration,delegate: self,delegateQueue: operationQueue)
    }()
    
    private let dataStore = DataStoreImpl.Shared
    
    private override init(){
        //
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    }
}

///MARK:-
///Hook for handling SSL pinning
extension WeatherWorkerImpl: URLSessionDelegate{
    //MARK: Hook SSL Pinning Module
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        //
        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}


@available(iOS 13.0, *)
extension WeatherWorkerImpl {
    
    //MARK:-
    public func loadCurrentWeather(withLocation coords: (Double,Double)) -> AnyPublisher<WeatherItem, RequestState> {
        //
        let urlComponents = RequestBuider.buildWeatherApiComponents(latitude: coords.0, longitude: coords.1)
        //
        guard let url = urlComponents.url else {
          let error = RequestState.networkError(description: "Couldn't create Weather API URL")
          return Fail(error: error).eraseToAnyPublisher()
        }
        //
         return requestsSession.dataTaskPublisher(for: URLRequest(url: url))
          .mapError { error in
            return .networkError(description: error.localizedDescription)
          }
          .subscribe(on: dispatchQueue)
          .flatMap(maxPublishers: .max(1)) { pair in
              ResponseDecoder.decode(pair.data)
          }
          //.map(Array.removeDuplicates)
          .eraseToAnyPublisher()
        //
    }
    
    //MARK:-
    public func loadForecastWeather(forLocation coords: (Double,Double)) -> AnyPublisher<ForecastItem, RequestState>{
        //
        let urlComponents = RequestBuider.buildForecastApiComponents(latitude: coords.0, longitude: coords.1)
        //
        guard let url = urlComponents.url else {
          let error = RequestState.networkError(description: "Couldn't create Github URL")
          return Fail(error: error).eraseToAnyPublisher()
        }
        //
        return requestsSession.dataTaskPublisher(for: URLRequest(url: url))
          .mapError { error in
            .networkError(description: error.localizedDescription)
          }
          .subscribe(on: dispatchQueue)
          .flatMap(maxPublishers: .max(1)) { pair in
              ResponseDecoder.decode(pair.data)
          }
          .map({ response in
              _ = self.dataStore.addForecastItem(with: response)
              return response
          })
          .eraseToAnyPublisher()
    }
}


extension WeatherWorkerImpl {
    
    
    public func loadCurrentWeather(withLocation coords: (Double,Double),_ completion: @escaping ( WeatherItem?, RequestState) -> Void) -> Swift.Void{
        
        //
        let urlComponents = RequestBuider.buildWeatherApiComponents(latitude: coords.0, longitude: coords.1)
        //
        guard let url = urlComponents.url else {
            let error = RequestState.networkError(description: "Couldn't create Weather API URL")
            completion(nil,error)
            return
        }
        
        
        let task = requestsSession.dataTask(with: url, completionHandler: { responseData, httpResponse, error in
            
            //
            guard let data = responseData, error == nil else {
                // check for fundamental networking error
                completion(nil,RequestState.networkError(description: error?.localizedDescription ?? "Network Call Failed."))
                return
            }
            //
            if let httpStatus = httpResponse as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                LogUtils.Log(from:self,with:"Resp Code = \(httpStatus.statusCode), \n Failure Response: \(String(describing: httpStatus))")
                //
                completion(nil,RequestState.networkError(description: "Network Call Failed."))
                //
                return
            }
            //
            
            guard let responseString = String(data: data, encoding: .utf8) else{
                //
                completion(nil,RequestState.parsingError(description: "Unreadable repose from http Response"))
                return
            }
            LogUtils.Log(from: self, with: responseString)
            
            
            //
            let decoder = JSONDecoder()
            //
            guard let payload = try? decoder.decode(WeatherItem.self, from: data) else {
                LogUtils.Log(from:self,with:"Error: Couldn't decode to Forecast Data.")
                completion(nil,RequestState.parsingError(description: "Couldn't decode to Forecast Data."))
                return
            }
            
            completion(payload,RequestState.none(description: "Success"))
        })
        task.resume()
        
    }
    
    public func loadForecastWeather(forLocation coords: (Double,Double), _ completion: @escaping ( ForecastItem?, RequestState) -> Void) -> Swift.Void{
        
        //
        let urlComponents = RequestBuider.buildForecastApiComponents(latitude: coords.0, longitude: coords.1)
        //
        guard let url = urlComponents.url else {
            let error = RequestState.networkError(description: "Couldn't create Weather API URL")
            completion(nil,error)
            return
        }
        
        
        let task = requestsSession.dataTask(with: url, completionHandler: { responseData, httpResponse, error in
            
            //
            guard let data = responseData, error == nil else {
                // check for fundamental networking error
                completion(nil,RequestState.networkError(description: error?.localizedDescription ?? "Network Call Failed."))
                return
            }
            //
            if let httpStatus = httpResponse as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                LogUtils.Log(from:self,with:"Resp Code = \(httpStatus.statusCode), \n Failure Response: \(String(describing: httpStatus))")
                //
                completion(nil,RequestState.networkError(description: "Network Call Failed."))
                //
                return
            }
            //
            
            guard let responseString = String(data: data, encoding: .utf8) else{
                //
                completion(nil,RequestState.parsingError(description: "Unreadable repose from http Response"))
                return
            }
            LogUtils.Log(from: self, with: responseString)
            
            
            //Decoder
            let decoder = JSONDecoder()
            //
            guard let payload = try? decoder.decode(ForecastItem.self, from: data) else {
                LogUtils.Log(from:self,with:"Error: Couldn't decode to Forecast Data.")
                completion(nil,RequestState.parsingError(description: "Couldn't decode to Forecast Data."))
                return
            }
            
            completion(payload,RequestState.none(description: "Success"))
            
            //Cache the item,
            _ = self.dataStore.addForecastItem(with: payload)
            
        })
        task.resume()
    }
}
