//
//  WeatherViewModel.swift
//  weatherapp
//
//  Created by Bourne Koloh on 05/08/2023.
//

import Foundation
import Combine
import SwiftUI
import weathercore
import CoreLocation

@available(iOS 13.0, *)
internal class WeatherViewModel : NSObject, ObservableObject{
    
    private let locationManager = CLLocationManager()
    
    let defaultLocation = CLLocation(latitude: -1.2822074, longitude: 36.819080)
    
    //User Location ,...
    @Published var location: CLLocation?
    @Published var showLocationServicesAlert = false
    @Published var showPermissionsAlert = false
    //Error reporting
    @Published var showErrorAlert = false
    @Published var errorMessage: String = ""
    //
    @Published var isLoading = false
    @Published var isRefreshing = false
    
    //In-Memory firecast persistance
    @Published var forecastEntries: [WeatherItem] = []
    
    //In-Memory weather persistance
    @Published var currentTemp = "~"
    @Published var currentWeather = "~ ~"
    @Published var currentMinTemp = "~"
    @Published var currentMaxTemp = "~"
    @Published var currentImage = "sea-cloudy"
    @Published var currentBackgroundColor = UIUtils.colorWeatherSeaClouds
    //Weather API service
    @Environment(\.weatherService) var apiService: IWeatherWorker
    //Weather API service
    @Environment(\.dataStoreService) var dataStore: IDataStore
    //Cache for tasks
    private var disposables = Set<AnyCancellable>()
    
    //
    let dateFormatter = DateFormatter()
    
    private let dispatchQueue:DispatchQueue
    
    //MARK:- Initializer
    init(scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")) {
        dispatchQueue = scheduler
        super.init()
        //
        self.locationManager.delegate = self
        
        //
        $location
        //
        .sink(receiveValue: updateForecast(withLocation:))
        //
        .store(in: &disposables)
        //
    }
    
    public func requestLocationAccessAuthorisation() {
        
        //
        dispatchQueue.async {[weak self] in
            
            //
            guard let self = self else { return }
            //
            if CLLocationManager.locationServicesEnabled() {
                // Ask for Authorisation from User.
                self.locationManager.requestAlwaysAuthorization()
                // For use in foreground
                self.locationManager.requestWhenInUseAuthorization()
            }else{
                self.showLocationServicesAlert = true
            }
        }
    }
    
    internal func processForecastData(_ forecast:ForecastItem){
        
        self.dateFormatter.dateFormat = "dd-MM-yyyy"
        //
        var filtered = [WeatherItem]()
        //
        var index = 1
        for weather in forecast.entries.filter({ item in
            return item.dt >= Date()
        }) {
            weather.id = UInt64(index)
            if !filtered.contains(where: {self.dateFormatter.string(from: $0.dt) == self.dateFormatter.string(from: weather.dt) }) {
                filtered.append(weather)
            }
            index += 1 //Add unique IDs of UI rendering with Identifiable protocol
        }
        //
        self.forecastEntries = Array(filtered.dropFirst())
    }
    
    internal func processWeatherData(_ weather:WeatherItem){
        self.currentTemp = "\(Int(weather.main?.temp ?? 0))°"
        self.currentMaxTemp = "\(Int(weather.main?.tempMax ?? 0))°"
        self.currentMinTemp = "\(Int(weather.main?.tempMin ?? 0))°"
        self.currentWeather = weather.weather.first?.main ?? ""
        self.currentImage = weather.weather.first?.main == "Clouds" ? "sea-cloudy" : weather.weather.first?.main == "Rain" ? "sea-rainy" : "sea-sunny"
        self.currentBackgroundColor = weather.weather.first?.main == "Clouds" ? UIUtils.colorWeatherSeaClouds : weather.weather.first?.main == "Rain" ? UIUtils.colorWeatherSeaRain : UIUtils.colorWeatherSeaSunny
    }
    
    public func refreshData(){
        
        isRefreshing = true
        
        updateForecast(withLocation: location)
    }
    ///Call to fetch  weather forecast from API
    /// - Parameter withLocation: optional `CLLocation` user location
    internal func updateForecast(withLocation loc: CLLocation?) {
        //
        guard let curLocation = loc else{
            return
        }
        //Update on main thread
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        //Fetch forecast
        apiService.loadForecastWeather(forLocation: (curLocation.coordinate.latitude, curLocation.coordinate.longitude))
        //
        .receive(on: DispatchQueue.main)
        //
        .sink(
          receiveCompletion: { [weak self] apiError in
              //
              guard let self = self else { return }
              //
              self.isLoading = false
              
              self.isRefreshing = false
              //
              switch apiError {
              case .failure(let value):
                    self.errorMessage = value.localizedDescription
                    self.showErrorAlert = true
                    self.forecastEntries = []
                case .finished:
                  break
              }
          },
          receiveValue: { [weak self] forecast in
              //
              guard let self = self else { return }
              //
              
              self.processForecastData(forecast)
        })
        //
        .store(in: &disposables)
        
        //Fetch Current Weather
        apiService.loadCurrentWeather(withLocation:(curLocation.coordinate.latitude, curLocation.coordinate.longitude))
        //
        .receive(on: DispatchQueue.main)
        //
        .sink(
          receiveCompletion: { [weak self] apiError in
              //
              guard let self = self else { return }
              //
              self.isLoading = false
              //
              switch apiError {
              case .failure(let value):
                    self.errorMessage = value.localizedDescription
                    self.showErrorAlert = true
                    self.forecastEntries = []
                case .finished:
                  break
              }
          },
          receiveValue: { [weak self] weather in
              //
              guard let self = self else { return }
              //
              self.processWeatherData(weather)
        })
        //
        .store(in: &disposables)
    }
    
    func loadCachedWeather(){
        
        let cache = dataStore.loadForecastItems()
        
        if !cache.isEmpty, let forecast = cache.first {
            //
            processForecastData(forecast)
            //
            if let weather = forecast.entries.filter({ item in
                return item.dt > Date()
            }).filter({ item in
                return dateFormatter.string(from: item.dt) == dateFormatter.string(from: Date())
            }).first{
                //
                processWeatherData(weather)
            }
        }
    }
}

@available(iOS 13.0, *)
extension WeatherViewModel: CLLocationManagerDelegate {

    func locationManager(_ clmanager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
                break
        case .notDetermined,.restricted,.denied:
            self.showPermissionsAlert = true
            break
        @unknown default:
                break
        }
        
    }
    // MARK: - CL Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else {
            //
            return
        }
        //
        self.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        //
        LogUtils.Log(from:self,with:"Curr location :: lat =\(location.latitude), lng = \(location.longitude)")
        //
        locationManager.stopUpdatingLocation()
    }
}
