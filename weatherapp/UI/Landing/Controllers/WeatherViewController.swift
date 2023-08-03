//
//  SplashViewController.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation
import UIKit
import weathercore
import CoreLocation

class WeatherViewController:UIViewController {
    
    private let defaultLocation = CLLocation(latitude: -1.2822074, longitude: 36.819080)
    
    private var forecast:ForecastItem? = nil
    
    private var userLocation:CLLocation?
    
    private var locationManager = CLLocationManager()
    
    private let preferedTableRowHeight = CGFloat(36)
    
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
        dateFormatter.dateFormat = "EEEE"
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
                        case .notDetermined, .restricted, .denied:
                            weakSelf?.notifyLocationPermissionsDenied()
                            break
                        case .authorizedAlways, .authorizedWhenInUse:
                            
                            weakSelf?.locationManager.delegate = self
                            weakSelf?.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                            weakSelf?.locationManager.startUpdatingLocation()
                            break
                        @unknown default:
                            break
                    }
                }
                
            }else{
                //Run on main thread
                DispatchQueue.main.async {[weak weakSelf = weakController] in
                    weakController?.notifyLocationServicesNotAvailable()
                }
            }
            
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateWeather(_ update:WeatherItem?){
        
        if let weather = update {
            //
            temperatureLabel.text = "\(weather.main?.temp ?? 0)°"
            //
            weatherTitleLabel.text = weather.weather?.main ?? "~ ~"
            //
            minTemperatureLabel.text = "\(weather.main?.temp ?? 0)°"
            //
            currentTemparatureLabel.text = "\(weather.main?.temp ?? 0)°"
            //
            maxTemperatureLabel.text = "\(weather.main?.tempMax ?? 0)°"
            
            switch(weather.weather?.main){
                case "Rain":
                weatherImageView.image = UIImage(named: "sea-rainy")
                view.backgroundColor = UIColor(displayP3Red: CGFloat(0), green: CGFloat(), blue: CGFloat(), alpha: CGFloat(1))
                    break
                case "Sunny":
                weatherImageView.image = UIImage(named: "sea-sunny")
                view.backgroundColor = UIColor(displayP3Red: CGFloat(0), green: CGFloat(), blue: CGFloat(), alpha: CGFloat(1))
                    break
                case "Cloudy":
                weatherImageView.image = UIImage(named: "sea-cloudy")
                view.backgroundColor = UIColor(displayP3Red: CGFloat(87), green: CGFloat(87), blue: CGFloat(93), alpha: CGFloat(1))
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
        updateWeather(nil)
        //
        toggleLoader(true, nil)
        //
        WeatherWorkerImpl.getImpl().loadCurrentWeather(withLocation: (location.coordinate.latitude, location.coordinate.longitude), { weather, error in
            //
            DispatchQueue.main.async {[weak weakSelf = self] in
                //
                if(weather != nil){
                    //
                    weakSelf?.updateWeather(weather)
                }else{
                    
                    let alert = UIAlertController(title: "Load Forecast Failed", message: "There wan an issue while updating the weather forecast for your location.\n\nPlease try again later ..", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Try Again ..", style: .default, handler: { [weak alert, weak weakSelf = self] (_) in
                        //
                        
                        weakSelf?.loadForecast()
                        //
                        alert?.dismiss(animated: true, completion: nil)
                    }))
                    //
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { [weak alert, weak weakSelf = self] (_) in
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
        //
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        //
        WeatherWorkerImpl.getImpl().loadForecastWeather(forLocation: (location.coordinate.latitude, location.coordinate.longitude), { forecast, error in
            //
            DispatchQueue.main.async {[weak weakSelf = self] in
                //
                if(forecast != nil){
                    weakSelf?.forecast = forecast
                    //
                    weakSelf?.forecastTableView.reloadData()
                }else{
                    
                    let alert = UIAlertController(title: "Load Forecast Failed", message: "There wan an issue while updating the weather forecast for your location.\n\nPlease try again later ..", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Try Again ..", style: .default, handler: { [weak alert, weak weakSelf = self] (_) in
                        //
                        
                        weakSelf?.loadForecast()
                        //
                        alert?.dismiss(animated: true, completion: nil)
                    }))
                    //
                    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { [weak alert, weak weakSelf = self] (_) in
                        //
                        alert?.dismiss(animated: true, completion: nil)
                    }))
                    //
                    self.present(alert, animated: true,completion: nil)
                }
                
                //
                weakSelf?.refreshControl.endRefreshing()
            }
        })
    }
    
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
    
    private func notifyLocationServicesNotAvailable(){
        
        let alert = UIAlertController(title: "Location Access Failed", message: "It appears your device does not have location services or they have been disable.\n\nThis app requires your location to work properly", preferredStyle: .alert)
        
        
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
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { [weak alert, weak weakSelf = self] (_) in
            
            //
            alert?.dismiss(animated: true, completion: nil)
        }))
        //
        self.present(alert, animated: true,completion: nil)
    }
}


extension WeatherViewController: CLLocationManagerDelegate {
    // MARK: - CL Manager Delegate
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
        
        //
        return forecast?.entries.count ?? 0
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ForecastTableCell
        //
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.accessoryType = UITableViewCell.AccessoryType.none
        //cell.selectionStyle = UITableViewCell.SelectionStyle.gray;
        var item = forecast!.entries[indexPath.row]
        
        //Clear
        cell.DayLabel.text = dateFormatter.string(from: item.dt)
        
        switch(item.weather?.main){
            case "Rain":
            cell.WeatherIcon.image = UIImage(named: "rain")
                break
            case "Sunny":
            cell.WeatherIcon.image = UIImage(named: "partlysunny")
                break
            case "Cloudy":
            cell.WeatherIcon.image = UIImage(named: "clear")
                break
        case .none,.some(_):
            break
        }
        //
        cell.TempLabel.text = "\(item.main?.temp ?? 0.0)°"
        //
        return cell
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
        var item = forecast?.entries[indexPath.row]
        
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
                    
                    //Height with respect to stroryboard design device (iPhone XS Max)
                    let screenHeightRatio = UIScreen.main.bounds.height / 896.0
                    //Width ratio with respect to  stroryboard design device (iPhone XS Max)
                    let screenWidthRatio = UIScreen.main.bounds.width / 414.0
                    
                    //
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    
                        w = max(200,130 * max(screenWidthRatio,screenHeightRatio))
                        //min(rootVC.view.frame.size.width / 2 , rootVC.view.frame.size.height / 5)
                           
                        h = max(200,130 * max(screenWidthRatio,screenHeightRatio))
                    }else{
                        w = max(180,130 * max(screenWidthRatio,screenHeightRatio))
                        //min(rootVC.view.frame.size.width / 2 , rootVC.view.frame.size.height / 5)
                           
                        h = max(180,130 * max(screenWidthRatio,screenHeightRatio))
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
