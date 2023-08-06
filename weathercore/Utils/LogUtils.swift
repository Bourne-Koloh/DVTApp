//
//  LogUtils.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation
public class LogUtils{
    
    public static func Log(from obj:AnyObject, with :String){
        //
        #if DEBUG
        //Unccoment to write to lldb console
        //print("\(String(describing: type(of: obj))) ≈> \(with)")
        #endif
    }
}
