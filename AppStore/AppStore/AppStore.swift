//
//  AppStore.swift
//  AppStore
//
//  Created by Gene Backlin on 12/12/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import Foundation

public class AppStore: NSObject {
    
    public static func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return IAPProductDefinition.store.isProductPurchased(productIdentifier)
    }

}
