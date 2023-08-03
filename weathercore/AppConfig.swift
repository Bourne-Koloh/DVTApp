//
//  AppConfig.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import Foundation


public class AppConfig:NSObject{
    
    fileprivate static let DEFAULT_USER_STORE_KEY = "app-cache"
    
    fileprivate static var _config: AppConfig?
    
    public static var Shared:AppConfig{
        get {
            if _config == nil {
                //Init...
                _config = AppConfig()
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
    }
    
    //
    public var useSwiftUI:Bool = false
    public var isDevt:Bool = true
}
