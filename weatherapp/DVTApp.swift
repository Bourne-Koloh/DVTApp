//
//  DVTApp.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation
import UIKit
import weathercore

class DVTApp: UIApplication {
    //
    var idleTimer: Timer?
    
    override init() {
        super.init()
        //
    }
    //
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
    }
    //
    override func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any] = [:], completionHandler completion: ((Bool) -> Void)? = nil) {
        LogUtils.Log(from:self,with:"Accessing Path \(String(describing: url.host))")
        super.open(url, options: options, completionHandler: completion)
    }
}
