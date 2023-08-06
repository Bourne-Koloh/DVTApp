//
//  HostingViewController.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//  Email : bournekolo@icloud.com
//

import UIKit
import SwiftUI

@available(iOS 13.0, *)
class HostingViewController<C> : UIHostingController<C> where C : View  {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
