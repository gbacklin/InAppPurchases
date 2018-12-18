//
//  IAPProductDefinition.swift
//  InAppPurchase
//
//  Created by Gene Backlin on 12/12/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//
// https://developer.apple.com/in-app-purchase/
//

import Foundation

public struct IAPProductDefinition {
    public static var productIdentifiers: Set<ProductIdentifier> = []
    public static var store: IAPHelper!
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

