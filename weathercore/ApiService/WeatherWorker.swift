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

public protocol IWeatherWorker:NSObject {
    
    static func getImpl() -> IWeatherWorker
    /// Load all repositories, an optional filter for repo title
    /// - Warning: -
    /// - Parameter serahcTitle: optional `String` ther report title
    /// - Returns: alist of `GitRepoItem` objects.
    @available(iOS 13.0, *)
    func loadCurrentWeather(withLocation coords: (Double,Double)) -> AnyPublisher<WeatherItem?, RequestState>
    /// Load details of a git repository
    /// - Warning: -
    /// - Parameter repo: The `GitRepoItem` to be loaded.
    /// - Returns: The repository details, if the request failed, a nil is returned
    @available(iOS 13.0, *)
    func loadForecastWeather(forLocation coords: (Double,Double)) -> AnyPublisher<ForecastItem?, RequestState>
    
    
    //IMPL for iOS  < 13.0
    /// Load all repositories, an optional filter for repo title
    /// - Warning: -
    /// - Parameter serahcTitle: optional `String` ther report title
    /// - Returns: alist of `GitRepoItem` objects.
    func loadCurrentWeather(withLocation coords: (Double,Double),_ completion: @escaping ( WeatherItem?, RequestState) -> Void) -> Swift.Void
    /// Load details of a git repository
    /// - Warning: -
    /// - Parameter repo: The `GitRepoItem` to be loaded.
    /// - Returns: The repository details, if the request failed, a nil is returned
    func loadForecastWeather(forLocation coords: (Double,Double), _ completion: @escaping ( ForecastItem?, RequestState) -> Void) -> Swift.Void
}

extension IWeatherWorker{
    
    public static func getImpl() -> IWeatherWorker{
        return WeatherWorkerImpl.Shared
    }
}

///The class f=managing all requests in this app
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
    public func loadCurrentWeather(withLocation coords: (Double,Double)) -> AnyPublisher<WeatherItem?, RequestState> {
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
    public func loadForecastWeather(forLocation coords: (Double,Double)) -> AnyPublisher<ForecastItem?, RequestState>{
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
        var urlComponents = RequestBuider.buildForecastApiComponents(latitude: coords.0, longitude: coords.1)
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
            guard let payload = try? decoder.decode(ForecastItem.self, from: data) else {
                LogUtils.Log(from:self,with:"Error: Couldn't decode to Forecast Data.")
                completion(nil,RequestState.parsingError(description: "Couldn't decode to Forecast Data."))
                return
            }
            
            completion(payload,RequestState.none(description: "Success"))
            
        })
        task.resume()
    }
}
