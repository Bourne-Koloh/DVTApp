//
//  SplashViewController.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation
import UIKit
import weathercore
import CoreLocation

class WeatherViewController:UIViewController {
    
    private let defaultLocation = CLLocation(latitude: -1.2822074, longitude: 36.819080)
    
    private var forecastEntries = [WeatherItem]()
    
    private var userLocation:CLLocation?
    
    private var locationManager = CLLocationManager()
    
    private var apiService:IWeatherWorker = WeatherWorkerImpl.getImpl()
    
    private let preferedTableRowHeight = CGFloat(48)
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherTitleLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var currentTemparatureLabel: UILabel!
    
    @IBOutlet weak var forecastTableView: UITableView!
    
    fileprivate weak var loadingView:LoaderView?
    
    fileprivate var loaderBlurView:UIVisualEffectView?
    
    private var refreshControl:UIRefreshControl!
    
    private let dispatchQueue = DispatchQueue(label: "dvtapp.queue.dispatcheueuq")
    //
    let dateFormatter = DateFormatter()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //
        self.forecastTableView.dataSource = self
        self.forecastTableView.delegate = self
        self.forecastTableView.separatorStyle = .none
        self.forecastTableView.rowHeight = CGFloat(preferedTableRowHeight)
        //
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadForecast), for: .valueChanged)
        forecastTableView.addSubview(refreshControl)
        
        // Ask for Authorisation from User.
        self.locationManager.requestAlwaysAuthorization()
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        //
        locationManager.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Run on background thread,,
        dispatchQueue.async {[weak weakController = self] in
            
            if CLLocationManager.locationServicesEnabled() {
                //Run on main thread
                DispatchQueue.main.async {[weak weakSelf = weakController] in
                    //
                    switch CLLocationManager.authorizationStatus() {
                    case .notDetermined:
                        //User has not responded to request yet ..
                        break
                    case.restricted, .denied:
                            weakSelf?.notifyLocationPermissionsDenied()
                            break
                        case .authorizedAlways, .authorizedWhenInUse:
                            //Allowed.
                            break
                        @unknown default:
                            break
                    }
                }
                
            }else{
                //Run on main thread
                DispatchQueue.main.async {[weak weakSelf = weakController] in
                    weakSelf?.notifyLocationServicesNotAvailable()
                }
            }
            
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func processWeatherData(_ update:WeatherItem?){
        
        if let weather = update {
            //
            temperatureLabel.text = "\(Int(weather.main?.temp.rounded() ?? 0))°"
            //
            weatherTitleLabel.text = weather.weather.first?.main ?? "~ ~"
            //
            minTemperatureLabel.text = "\(Int(weather.main?.tempMin.rounded() ?? 0))°"
            //
            currentTemparatureLabel.text = "\(Int(weather.main?.temp.rounded() ?? 0))°"
            //
            maxTemperatureLabel.text = "\(Int(weather.main?.tempMax.rounded() ?? 0))°"
            
            switch(weather.weather.first?.main){
                case "Rain":
                weatherImageView.image = UIImage(named: "sea-rainy")
                view.backgroundColor = UIUtils.colorWeatherSeaRain
                    break
                case "Clear":
                weatherImageView.image = UIImage(named: "sea-sunny")
                view.backgroundColor = UIUtils.colorWeatherSeaSunny
                    break
                case "Clouds":
                weatherImageView.image = UIImage(named: "sea-cloudy")
                view.backgroundColor = UIUtils.colorWeatherSeaClouds
                    break
            case .none,.some(_):
                break
            }
        }else{
            //Clear fields
            //
            temperatureLabel.text = "~"
            //
            weatherTitleLabel.text = "~ ~"
            //
            minTemperatureLabel.text = "~"
            //
            currentTemparatureLabel.text = "~"
            //
            maxTemperatureLabel.text = "~"
            
        }
    }
    
    private func processForecastData(_ forecast:ForecastItem){
        //
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        //Pick One Entry per day,
        var filtered = [WeatherItem]()
        //
        for weather in forecast.entries {
            if !filtered.contains(where: {dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval($0.dt))) == dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt))) }) {
                filtered.append(weather)
            }
        }
        //Clear cache
        forecastEntries.removeAll()
        //Add to cache,,
        forecastEntries.append(contentsOf: filtered.dropFirst()) //Remove todays weather
        //
        dateFormatter.dateFormat = "EEEE"
        //
        forecastTableView.reloadData()
    }
    
    @objc func loadCurrentWeather(){
        //
        guard let location = userLocation else{
            //
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            //
            return
        }
        //
        processWeatherData(nil)
        //
        toggleLoader(true, nil)
        //
        apiService.loadCurrentWeather(withLocation: (location.coordinate.latitude, location.coordinate.longitude), { weather, error in
            //
            DispatchQueue.main.async {[weak weakSelf = self] in
                //
                if(weather != nil){
                    //
                    weakSelf?.processWeatherData(weather)
                }else{
                    
                    let alert = UIAlertController(title: "Load Forecast Failed", message: "There wan an issue while updating the weather forecast for your location.\n\nPlease try again later ..", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Try Again ..", style: .default, handler: { [weak alert, weak weakSelf = self] (_) in
                        //
                        
                        weakSelf?.loadCurrentWeather()
                        //
                        alert?.dismiss(animated: true, completion: nil)
                    }))
                    //
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { [weak alert] (_) in
                        //
                        alert?.dismiss(animated: true, completion: nil)
                    }))
                    //
                    self.present(alert, animated: true,completion: nil)
                }
                //
                weakSelf?.toggleLoader(false, nil)
            }
        })
    }
    
    ///Load Forecast
    @objc func loadForecast(){
        //
        guard let location = userLocation else{
            //
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            //
            return
        }
        //Show Loader
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        //
        apiService.loadForecastWeather(forLocation: (location.coordinate.latitude, location.coordinate.longitude), { forecast, error in
            //
            DispatchQueue.main.async {[weak weakSelf = self] in
                //
                if(forecast != nil){
                    
                    weakSelf?.processForecastData(forecast!)
                }else{
                    
                    let alert = UIAlertController(title: "Load Forecast Failed", message: "There wan an issue while updating the weather forecast for your location.\n\nPlease try again later ..", preferredStyle: .actionSheet)
                    
                    alert.addAction(UIAlertAction(title: "Try Again ..", style: .default, handler: { [weak alert, weak weakSelf = self] (_) in
                        //
                        
                        weakSelf?.loadForecast()
                        //
                        alert?.dismiss(animated: true, completion: nil)
                    }))
                    //
                    alert.addAction(UIAlertAction(title: "Use Offline Data", style: .cancel, handler: { [weak alert, weak weakSelf = self] (_) in
                        //
                        alert?.dismiss(animated: true, completion: nil)
                        //
                        weakSelf?.loadCachedWeather()
                    }))
                    //
                    self.present(alert, animated: true,completion: nil)
                    
                }
                
                //
                weakSelf?.refreshControl.endRefreshing()
            }
        })
    }
    
    ///Load weather data from cache
    private func loadCachedWeather(){
        
        let cache = DataStoreImpl.Shared.loadForecastItems()
        
        if !cache.isEmpty, let forecast = cache.first {
            //
            processForecastData(forecast)
            //
            if let weather = forecast.entries.filter({ item in
                return Date(timeIntervalSince1970: TimeInterval(item.dt)) > Date()
            }).filter({ item in
                return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(item.dt))) == dateFormatter.string(from: Date())
            }).first{
                //
                processWeatherData(weather)
            }
        }
    }
    
    ///Notify User
    private func notifyLocationPermissionsDenied(){
        
        let alert = UIAlertController(title: "Location Access Failed.", message: "Please allow the app to access your location and fetch weather update for your current location\n\nThis app requires your location to work properly", preferredStyle: .actionSheet)
        
        //Check if running on a teblet ..
        if let _ = alert.popoverPresentationController {
            //We are running in a tablet, apply necessary modification ..
        }
        
        alert.addAction(UIAlertAction(title: "Allow Access ..", style: .default, handler: { [weak alert, weak weakSelf = self] (_) in
            //
            if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }else{
                LogUtils.Log(from: weakSelf!, with: "Could NOT get reference to Device Settings")
            }
            //
            alert?.dismiss(animated: true, completion: nil)
        }))
        //
        alert.addAction(UIAlertAction(title: "Use Dafault Location", style: .cancel, handler: { [weak alert, weak weakSelf = self] (_) in
            //
            weakSelf!.userLocation = weakSelf!.defaultLocation
            //
            weakSelf?.loadForecast()
            //
            alert?.dismiss(animated: true, completion: nil)
        }))
        //
        self.present(alert, animated: true,completion: nil)
    }
    
    ///Notify user
    private func notifyLocationServicesNotAvailable(){
        
        let alert = UIAlertController(title: "Location Services Missing", message: "It appears your device does not have location services or they have been disable.\n\nThis app requires your location to work properly", preferredStyle: .alert)
        
        
        //Check if running on a teblet ..
        if let _ = alert.popoverPresentationController {
            //We are running in a tablet, apply necessary modification ..
        }
        
        alert.addAction(UIAlertAction(title: "Use Dafault Location", style: .default, handler: { [weak alert, weak weakSelf = self] (_) in
                //
                weakSelf!.userLocation = weakSelf!.defaultLocation
                //
                weakSelf?.loadForecast()
            //
            alert?.dismiss(animated: true, completion: nil)
        }))
        //
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { [weak alert] (_) in
            
            //
            alert?.dismiss(animated: true, completion: nil)
        }))
        //
        self.present(alert, animated: true,completion: nil)
    }
}

///Extension for Handling Location Request Results
extension WeatherViewController: CLLocationManagerDelegate {
    
    // MARK: - CL Manager Delegate for handling permision changes
    func locationManager(_ clmanager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            //
        break
        case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
                break
        case .restricted,.denied:
            self.notifyLocationPermissionsDenied()
            break
        @unknown default:
                break
        }
        
    }
    // MARK: - CL Manager Delegate for handling location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else {
            //
            return
        }
        //
        userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        //
        LogUtils.Log(from:self,with:"Curr location :: lat =\(location.latitude), lng = \(location.longitude)")
        //
        locationManager.stopUpdatingLocation()
        //
        loadForecast()
        //
        loadCurrentWeather()
    }
    
}

extension WeatherViewController : UITableViewDataSource {
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Return 1 by default, to show the empty caption
        return forecastEntries.count > 1 ? forecastEntries.count : 1
    }
    
}

extension WeatherViewController:UITableViewDelegate{
     //
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if forecastEntries.count > 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ForecastTableCell
            //
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.accessoryType = UITableViewCell.AccessoryType.none
            //cell.selectionStyle = UITableViewCell.SelectionStyle.gray;
            let item = forecastEntries[indexPath.row]
            
            //Clear
            cell.DayLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(item.dt)))
            
            switch(item.weather.first?.main){
            case "Rain":
                cell.WeatherIcon.image = UIImage(named: "rain")
                break
            case "Clear":
                cell.WeatherIcon.image = UIImage(named: "clear")
                break
            case "Clouds":
                cell.WeatherIcon.image = UIImage(named: "partlysunny")
                break
            case .none,.some(_):
                break
            }
            //
            cell.TempLabel.text = "\(Int(item.main?.temp ?? 0.0))°"
            //
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! EmptyTableCell
            cell.CaptionLabel.text = "No Forecast Weather Loaded ..."
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Not supported
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
       
        //
        return nil
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
       
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        //
        _ = forecastEntries[indexPath.row]
        
        //
    }
}


extension WeatherViewController {
    
    private func toggleLoader(_ toShown:Bool, _ title:String?){
        //
        let rootVC = self
        //
        UIView.animate(withDuration: 0.4,delay: 0, options: .curveEaseOut, animations: {

            //
            rootVC.view.isUserInteractionEnabled = !toShown
            //
            if toShown {
                //
                if let loadingView = self.loadingView {
                    //
                    loadingView.titleLabelView.text = title ?? "Please Wait ..."
                }else{
                    let loadingView = UINib(nibName: "LoaderView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! LoaderView
                    //
                    loadingView.titleLabelView.text = title ?? "Please Wait ..."
                    
                    loadingView.translatesAutoresizingMaskIntoConstraints = false
                    rootVC.view.addSubview(loadingView)
                    //
                    var w = CGFloat(0.0), h = CGFloat(0.0)
                    
                    //
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    
                        w = max(200,130 * max(UIUtils.screenWidthRatio,UIUtils.screenHeightRatio))
                        h = max(200,130 * max(UIUtils.screenWidthRatio,UIUtils.screenHeightRatio))
                    }else{
                        w = max(180,130 * max(UIUtils.screenWidthRatio,UIUtils.screenHeightRatio))
                        h = max(180,130 * max(UIUtils.screenWidthRatio,UIUtils.screenHeightRatio))
                    }
                    //
                    loadingView.heightAnchor.constraint(equalToConstant: h).isActive = true
                    loadingView.widthAnchor.constraint(equalToConstant: w).isActive = true
                    //
                    loadingView.centerXAnchor.constraint(equalTo: rootVC.view.centerXAnchor).isActive = true
                    loadingView.centerYAnchor.constraint(equalTo: rootVC.view.centerYAnchor).isActive = true
                    loadingView.layer.cornerRadius = 8
                    loadingView.clipsToBounds = true
                    //
                    loadingView.activity.color = UIColor.white
                    loadingView.backgroundColor = UIUtils.colorAccent
                    //
                    self.loadingView = loadingView
                }
                
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
                let blurView = UIVisualEffectView(effect: blurEffect)
                blurView.frame = rootVC.view.bounds
                blurView.alpha = 0.65
                blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                rootVC.view.addSubview(blurView)
                //
                self.loaderBlurView = blurView
                //
                rootVC.view.bringSubviewToFront(self.loadingView!)
                
                //Show if available
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }else {
                //
                if let loadingView = self.loadingView{
                    loadingView.removeFromSuperview()
                }
                if let blur = self.loaderBlurView {
                    blur.removeFromSuperview()
                }
                //Hide if available
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
        })
    }
}
