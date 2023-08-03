//
//  IDataStore.swift
//  weathercore
//
//  Created by Bourne Koloh on 02/08/2023.
//

import Foundation

public protocol IDataStore {
    
    func dispose()
    
}

extension IDataStore{
    
    public static var Shared:IDataStore{
        //
        get{
            return DataStoreImpl.Shared
        }
        set{}
    }
}
