//
//  TabBarViewController.swift
//  expenses
//
//  Created by Antonio Santos on 8/2/19.
//  Copyright © 2019 Antonio Santos. All rights reserved.
//

import UIKit
import CoreData

class TabBarViewController: UITabBarController {
    var container: NSPersistentContainer!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard container != nil else {
            fatalError("This view needs a persistent container.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let transactionsNavigationController = viewControllers?[0] as? UINavigationController
        let transactionsViewController = transactionsNavigationController?.viewControllers.first as? TransactionsTableViewController
        transactionsViewController?.container = container
        
        let categoriesNavigationController = viewControllers?[1] as? UINavigationController
        let categoriesViewController = categoriesNavigationController?.viewControllers.first as? CategoriesTableViewController
        categoriesViewController?.container = container
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
