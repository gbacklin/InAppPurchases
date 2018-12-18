//
//  ProductListTableViewController.swift
//  AppStore
//
//  Created by Gene Backlin on 12/12/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit
import StoreKit

class ProductListTableViewController: UITableViewController {
    var products: [SKProduct] = []
    var restoreButton: UIBarButtonItem?
    var isProductsFound = false

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ProductListTableViewController.reload), for: .valueChanged)
        
        restoreButton = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(ProductListTableViewController.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        restoreButton!.isEnabled = false
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ProductListTableViewController.done(_:)))
        navigationItem.leftBarButtonItem = doneButton

        NotificationCenter.default.addObserver(self, selector: #selector(ProductListTableViewController.handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reload()
    }

}

// MARK: - Navigation

extension ProductListTableViewController {
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ShowProductDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return false
            }
            
            let product = products[(indexPath as NSIndexPath).row]
            
            return IAPProductDefinition.store.isProductPurchased(product.productIdentifier)
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProductDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let product = products[(indexPath as NSIndexPath).row]
            if let name = resourceNameForProductIdentifier(product.productIdentifier),
                let detailViewController = segue.destination as? DetailViewController {
                let image = UIImage(named: name)
                detailViewController.image = image
            }
        }
    }

}

// MARK: - Selector methods

extension ProductListTableViewController {
    @objc func reload() {
        products = []
        isProductsFound = false
        print("Reloading...")
        
        tableView.reloadData()
        
        IAPProductDefinition.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                if let productList = products {
                    if productList.count > 0 {
                        self.isProductsFound = true
                        self.restoreButton!.isEnabled = true
                        self.products = productList
                        self.tableView.reloadData()
                    } else {
                        self.restoreButton!.isEnabled = false
                    }
                } else {
                    self.restoreButton!.isEnabled = false
                }
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    @objc func done(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func restoreTapped(_ sender: AnyObject) {
        IAPProductDefinition.store.restorePurchases()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard
            let productID = notification.object as? String,
            let index = products.index(where: { product -> Bool in
                product.productIdentifier == productID
            })
            else { return }
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
}

// MARK: - UITableViewDataSource

extension ProductListTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 1
        
        if products.count > 0 {
            count = products.count
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductCell
        
        if isProductsFound {
            let product = products[(indexPath as NSIndexPath).row]
            
            cell.product = product
            cell.buyButtonHandler = { product in
                IAPProductDefinition.store.buyProduct(product)
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            cell.textLabel?.text = "Accessing AppStore..."
            cell.detailTextLabel?.text = ""
            cell.accessoryType = .none
        }
        
        return cell
    }
    
}
