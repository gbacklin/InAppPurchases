//
//  ViewController.swift
//  TestInAppPurchases
//
//  Created by Gene Backlin on 12/12/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit
import AppStore

class ViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        initializeIAPProducts()
        
        print("isPurchased = \(AppStore.isProductPurchased(IAPProductDefinition.StoreSeries))")
        print("isPurchased = \(AppStore.isProductPurchased(IAPProductDefinition.EnableLeagues))")
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DisplayPDF" {
            let controller: PDFViewerViewController = segue.destination as! PDFViewerViewController
            let pdfData = PDFConverter.convertView(view: view)
            controller.pdfData = pdfData
        }
    }
    
}

// MARK: - IAP initialization

extension IAPProductDefinition {
    public static let StoreSeries = "\(String(describing: Bundle.main.bundleIdentifier!)).storeseries"
    public static let EnableLeagues = "\(String(describing: Bundle.main.bundleIdentifier!)).enableleagues"
}

extension ViewController {
    func initializeIAPProducts() {
        IAPProductDefinition.productIdentifiers = [IAPProductDefinition.StoreSeries, IAPProductDefinition.EnableLeagues]
        IAPProductDefinition.store = IAPHelper(productIds: IAPProductDefinition.productIdentifiers)
    }
}
