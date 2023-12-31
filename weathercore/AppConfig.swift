//
//  AppConfig.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation

/**
 * MARK: This class is a singletone share current application configuration
 */
public class AppConfig:NSObject,Decodable{
    
    fileprivate static let DEFAULT_USER_STORE_KEY = "app-cache"
    
    fileprivate static var _config: AppConfig?
    
    public static var Shared:AppConfig{
        get {
            if _config == nil {
                //Init...
                _ = AppConfig()
                //Will use default values of Info.plist properties are not read,
                //_config = AppConfig()
            }
            
            return _config!
        }
    }
    
    public static var AppStore:[String:Any]{
        get{
            if let userInformation = UserDefaults.standard.dictionary(forKey: DEFAULT_USER_STORE_KEY){
                //Old value
                return userInformation
            }else{
                //New Instance
                let userInfo = [String:Any]()
                //
                UserDefaults.standard.set(userInfo, forKey: DEFAULT_USER_STORE_KEY)
                //
                return userInfo
            }
        }
        set{
            //Overwrite
            UserDefaults.standard.set(newValue, forKey: DEFAULT_USER_STORE_KEY)
        }
    }
    
    override init(){
        super.init()
        
        //
        do {
            //
            if let url = Bundle.main.url(forResource: "Info", withExtension: "plist") {
                //
                let data = try Data(contentsOf: url)
                //
                AppConfig._config = try PropertyListDecoder().decode(AppConfig.self, from: data)
                
            }else{
                
                LogUtils.Log(from:self,with:"Load Config Error :: Info.plist not found")
            }
        }catch{
            LogUtils.Log(from:self,with:"Load Config Error :: \(error)")
        }
        
    }
    
    //
    public var preferSwiftUI:Bool = false
    public var isDevt:Bool = true
    public var weatherKey:String? = nil
    
    
    
    //
    enum CodingKeys : String, CodingKey {
        case preferSwiftUI = "prefer-swiftui"
        case isDevt = "is-devt"
        case weatherKey = "weather-api-key"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let val = try? container.decodeIfPresent(Bool.self, forKey: .preferSwiftUI) {
            preferSwiftUI = val
        }
        if let val = try? container.decodeIfPresent(Bool.self, forKey: .isDevt){
            isDevt = val
        }
        if let val = try? container.decodeIfPresent(String.self, forKey: .weatherKey){
            weatherKey = val
        }
    }
}
